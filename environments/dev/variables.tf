variable "environment" {}

variable "application" {}

variable "vpc_cidr_block" {}

variable "user" {}

variable "team" {}

variable "key_name" {}

variable "availability_zones" {
  type = "list"
}

variable "subnet_size" {}

variable "subnet_assignment" {
  type = "map"

  default = {
    "nat"         = "1,2"    #"172.16.193.0/24
    "application" = "7,8"    #"172.16.199.0/24
  }
}
