variable "aws_vpc_parameters" {
  type = object({
    cidr   = string
    region = string
  })
  default = {
    cidr = "10.0.0.0/16"
    region = "ap-southeast-2"
  }
}

/**
* CIDR offsets
*/
variable "cidr_offsets" {
  type = object({
    management  = number
    external    = number
    internal    = number
    inspect_in  = number
    inspect_out = number
  })
  default = {
    management = 10
    external = 0
    internal = 20
    inspect_in = 40
    inspect_out = 50
  }
}

variable "tags" {
  type = object({
    prefix      = string
    environment = string
  })
  default = {
    prefix = "f5-sslo"
    environment = "demo"
  }
}
