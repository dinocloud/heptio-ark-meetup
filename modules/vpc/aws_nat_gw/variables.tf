variable "ngw_count" {}

variable "nat_subnet_ids" {
  type = "list"
}

variable "vpc_id" {}

variable "environment" {}

variable "name" {}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
