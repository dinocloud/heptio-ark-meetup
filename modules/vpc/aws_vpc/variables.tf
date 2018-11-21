variable "environment" {}

variable "user" {}

variable "name" {}

variable "cidr_block" {}

variable "instance_tenancy" {
  default = "default"
}

variable "enable_dns_support" {
  default = "true"
}

variable "enable_dns_hostnames" {
  default = "false"
}

variable "enable_classiclink" {
  default = "false"
}

variable "enable_classiclink_dns_support" {
  default = "false"
}

variable "assign_generated_ipv6_cidr_block" {
  default = "false"
}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
