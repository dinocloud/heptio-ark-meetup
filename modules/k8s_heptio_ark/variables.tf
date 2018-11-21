variable "application" {}

variable "environment" {}

variable "kubeconfig_origin" {}

variable "kubeconfig_dest" {}

variable "dest_region" {}

variable "extra_tags" {
  type    = "map"
  default = {}
}
