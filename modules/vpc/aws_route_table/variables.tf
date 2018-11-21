// module: aws_route_table

variable "propagating_vgws" {
  type    = "list"
  default = []
}

variable "available_az" {
  type = "list"
}

variable "vpc_id" {}

variable "cluster_name" {}

variable "purpose" {}

variable "route_table_count" {}

variable "identifier_tags" {
  type    = "map"
  default = {}
}

variable "s3_vpc_endpoint_id" {
  type    = "string"
  default = ""
}

variable "dynamodb_vpc_endpoint_id" {
  type    = "string"
  default = ""
}

variable "enable_s3_vpc_endpoint" {
  type    = "string"
  default = "0"
}

variable "enable_dynamodb_vpc_endpoint" {
  type    = "string"
  default = "0"
}
