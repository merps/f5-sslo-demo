## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.21 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.70 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.70 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | terraform-aws-modules/vpc/aws |  |

## Resources

| Name | Type |
|------|------|
| [random_id.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_vpc_parameters"></a> [aws\_vpc\_parameters](#input\_aws\_vpc\_parameters) | AWS VPC Input Parameters | <pre>object({<br>    cidr   = string<br>    region = string<br>  })</pre> | <pre>{<br>  "cidr": "10.0.0.0/16",<br>  "region": "ap-southeast-2"<br>}</pre> | no |
| <a name="input_cidr_offsets"></a> [cidr\_offsets](#input\_cidr\_offsets) | VPC CIDR Offsets for C Octet | <pre>object({<br>    management  = number<br>    external    = number<br>    internal    = number<br>    inspect_in  = number<br>    inspect_out = number<br>  })</pre> | <pre>{<br>  "external": 0,<br>  "inspect_in": 40,<br>  "inspect_out": 50,<br>  "internal": 20,<br>  "management": 10<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | AWS Tags | <pre>object({<br>    prefix      = string<br>    environment = string<br>  })</pre> | <pre>{<br>  "environment": "demo",<br>  "prefix": "f5-sslo"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_vpc"></a> [aws\_vpc](#output\_aws\_vpc) | n/a |
