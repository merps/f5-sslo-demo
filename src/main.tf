# Create Module using community
module "aws_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name                 = format("%s-min-%s", var.tags.prefix, var.tags.random)
  cidr                 = var.aws_vpc_parameters.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  azs = var.aws_vpc_parameters.azs

  # vpc public subnet used for external interface
  public_subnets = [for num in range(length(var.aws_vpc_parameters.azs)) :
    cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.external)
  ]

  # vpc private subnet used for internal
  private_subnets = [
    for num in range(length(var.aws_vpc_parameters.azs)) :
    cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.internal)
  ]
  enable_nat_gateway = true

  # using the database subnet method since it allows a public route
  database_subnets = [
    for num in range(length(var.aws_vpc_parameters.azs)) :
    cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.management)
  ]
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true
  database_subnet_tags = {
    Name = "Management"
  }

  # using the intra subnet method without public route for inspection in
  intra_subnets = [
    for num in range(length(var.aws_vpc_parameters.azs)) :
    cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.inspect_in)
  ]
  intra_subnet_tags = {
    Name = "InspectionIn"
  }

  # using the elasticache subnet method without public route for inspection out
  elasticache_subnets = [
    for num in range(length(var.aws_vpc_parameters.azs)) :
    cidrsubnet(var.aws_vpc_parameters.cidr, 8, num + var.cidr_offsets.inspect_out)
  ]
  elasticache_subnet_tags = {
    Name = "InspectionOut"
  }

  tags = {
    Name        = format("%s-min-%s", var.tags.prefix, var.tags.random)
    Terraform   = "true"
    Environment = var.tags.environment
  }
}