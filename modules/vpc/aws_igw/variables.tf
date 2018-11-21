variable "vpc_id" {}

variable "environment" {}

variable "name" {}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
