# Retrieve AWS regional zones
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = data.aws_availability_zones.available.names
}

# Initialise Random variable
resource "random_id" "id" {
  byte_length = 2
}

# Create random password for BIG-IP
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Create Secret Store and Store BIG-IP Password
resource "aws_secretsmanager_secret" "bigiq" {
  name = format("%s-secret-%s", var.tags.prefix, random_id.id.hex)
}

resource "aws_secretsmanager_secret_version" "bigiq-pwd" {
  secret_id     = aws_secretsmanager_secret.bigiq.id
  secret_string = random_password.password.result
}

# Create Module using community
module "aws_vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = format("%s-%s-%s", var.tags.prefix, var.tags.environment, random_id.id.hex)
  cidr                 = var.aws_vpc_parameters.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  azs = local.availability_zones

  # vpc public subnet used for external interface
  public_subnets = [
    for num in range(length(local.availability_zones)) :
    cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.external)
  ]
  public_subnet_tags = {
    Name        = format("%s-%s-public", var.tags.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = var.tags.environment
  }

  # vpc private subnet used for internal
  private_subnets = [
    for num in range(length(local.availability_zones)) :
    cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.internal)
  ]
  private_subnet_tags = {
    Name        = format("%s-%s-private", var.tags.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = var.tags.environment
  }

  enable_nat_gateway = true

  # using the database subnet method since it allows a public route
  database_subnets = [
    for num in range(length(local.availability_zones)) :
    cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.management)
  ]
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true
  database_subnet_tags = {
    Name        = format("%s-%s-mgmt", var.tags.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = var.tags.environment
  }

  # using the intra subnet method without public route for inspection in
  intra_subnets = [
    for num in range(length(local.availability_zones)) :
    cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.inspect_in)
  ]
  intra_subnet_tags = {
    Name        = format("%s-%s-sslo-in", var.tags.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = var.tags.environment
  }

  # using the elasticache subnet method without public route for inspection out
  elasticache_subnets = [
    for num in range(length(local.availability_zones)) :
    cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.inspect_out)
  ]
  elasticache_subnet_tags = {
    Name        = format("%s-%s-sslo-out", var.tags.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = var.tags.environment
  }
}

# Provision BIG-IQ (CM/DCD) for use within demo
module "big_iq_byol" {
  source = "github.com/merps/terraform-aws-bigiq"
  aws_secretmanager_secret_id = aws_secretsmanager_secret.bigiq.id
  cm_license_keys = [ var.licenses.cm_key ]
  ec2_key_name = var.ec2_public_key
  vpc_id = module.aws_vpc.vpc_id
  vpc_mgmt_subnet_ids = module.aws_vpc.database_subnets
  vpc_private_subnet_ids = module.aws_vpc.private_subnets
}

# Provision BIG-IP for the use of SSLO and BIG-IQ
#
# Create the BIG-IP appliances
#
module "bigip" {
  source = "github.com/merps/terraform-aws-bigip?ref=ip-outputs"
  prefix                      = format("%s-bigip-sslo_new_vpc-%s", var.tags.prefix, random_id.id.hex)
  aws_secretmanager_secret_id = aws_secretsmanager_secret.bigiq.id
  f5_instance_count = 2
  ec2_key_name                = var.ec2_public_key
  cloud_init = templatefile("${path.module}/files/do-declaration.tpl", {
    admin_pwd = random_password.password.result,
    root_pwd  = random_password.password.result,
    extSelfIP = join("/", [element(flatten(module.bigip.public_addresses.0), 0), 24])
    intSelfIP = join("/", [element(flatten(module.bigip.private_addresses.0), 0), 24])
    }
  )

  mgmt_subnet_security_group_ids = [
    module.bigip_sg.security_group_id,
    module.bigip_mgmt_sg.security_group_id
  ]

  public_subnet_security_group_ids = [
    module.bigip_sg.security_group_id,
    module.bigip_mgmt_sg.security_group_id
  ]

  private_subnet_security_group_ids = [
    module.bigip_sg.security_group_id,
    module.bigip_mgmt_sg.security_group_id
  ]

  vpc_public_subnet_ids  = module.aws_vpc.public_subnets
  vpc_private_subnet_ids = module.aws_vpc.private_subnets
  vpc_mgmt_subnet_ids    = module.aws_vpc.database_subnets
  }
#
# Create a security group for BIG-IP
#
module "bigip_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name        = format("%s-bigip-%s", var.tags.prefix, random_id.id.hex)
  description = "Security group for BIG-IP Demo"
  vpc_id      = module.aws_vpc.vpc_id
  ingress_cidr_blocks = []
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.bigip_sg.security_group_id
    }
  ]

  # Allow ec2 instances outbound Internet connectivity
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}
#
# Create a security group for BIG-IP Management
#
module "bigip_mgmt_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name        = format("%s-bigip-mgmt-%s", var.tags.prefix, random_id.id.hex)
  description = "Security group for BIG-IP Demo"
  vpc_id      = module.aws_vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "https-8443-tcp", "ssh-tcp"]
  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.bigip_mgmt_sg.security_group_id
    }
  ]

  # Allow ec2 instances outbound Internet connectivity
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}
