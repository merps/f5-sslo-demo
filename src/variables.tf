variable "aws_vpc_parameters" {
  type = object({
    cidr   = string
    azs    = list(string)
    region = string
  })
  default = {
    cidr = "10.0.0.0/16"
    azs = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
    region = "ap-southeast-2"
  }
}

variable "tags" {
  type = object({
    prefix      = string
    environment = string
    random      = string
  })
  default = {
    prefix = "f5-sslo"
    environment = "demo"
  }
}

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