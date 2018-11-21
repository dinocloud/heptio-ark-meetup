variable "environment" {}

variable "application" {}

variable "vpc_cidr_block" {}

variable "user" {}

variable "team" {}

variable "availability_zones" {
  type = "list"
}

variable "subnet_size" {}

variable "subnet_assignment" {
  type = "map"

  default = {
    "nat"         = "1,2,3"    #"172.16.193.0/24,172.16.194.0/24,172.16.195.0/24"
    "untrust"     = "4,5,6"    #"172.16.196.0/24,172.16.197.0/24,172.16.198.0/24"
    "application" = "7,8,9"    #"172.16.199.0/24,172.16.200.0/24,172.16.201.0/24"
    "persistance" = "10,11,12" #"172.16.202.0/24,172.16.203.0/24,172.16.204.0/24"
    "endpoints"   = "13,14,15" #"172.16.205.0/30,172.16.206.0/30,172.16.207.0/30"
  }
}

variable "extra_tags" {
  type = "map"
}

variable "eks_network_tags" {
  type = "map"
}

variable "region" {}

variable "subnet_size_endpoint" {
  default = "28"
}
