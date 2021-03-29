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

# Create Module using community
module "aws_vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = format("%s-%s-%s", var.tags.prefix, var.tags.environment, random_id.id.hex)
  cidr                 = var.aws_vpc_parameters.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  azs   = local.availability_zones

  # vpc public subnet used for external interface
  public_subnets = [
    for num in range(length(local.availability_zones)) :
      cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.external)
  ]
  public_subnet_tags = {
    Name        = format("%s-%s-ext", var.tags.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = var.tags.environment
  }

  # vpc private subnet used for internal
  private_subnets = [
    for num in range(length(local.availability_zones)) :
    cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.internal)
  ]
  private_subnet_tags = {
    Name        = format("%s-%s-int", var.tags.prefix, random_id.id.hex)
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
    Name        = format("%s-%s-inspec-out", var.tags.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = var.tags.environment
  }

  # using the intra subnet method without public route for inspection in
  intra_subnets = [
    for num in range(length(local.availability_zones)) :
    cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.inspect_in)
  ]
  intra_subnet_tags = {
    Name        = format("%s-%s-inspec-in", var.tags.prefix, random_id.id.hex, )
    Terraform   = "true"
    Environment = var.tags.environment
  }

  # using the elasticache subnet method without public route for inspection out
  elasticache_subnets = [
    for num in range(length(local.availability_zones)) :
    cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.inspect_out)
  ]
  elasticache_subnet_tags = {
    Name        = format("%s-%s-inspec-out", var.tags.prefix, random_id.id.hex)
    Terraform   = "true"
    Environment = var.tags.environment
  }
}