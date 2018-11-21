locals {
  vpc_name = "${var.environment}-${var.name}-vpc"
}

resource "aws_vpc" "main" {
  cidr_block                       = "${var.cidr_block}"
  instance_tenancy                 = "${var.instance_tenancy}"
  assign_generated_ipv6_cidr_block = "${var.assign_generated_ipv6_cidr_block}"
  enable_classiclink               = "${var.enable_classiclink}"
  enable_dns_hostnames             = "${var.enable_dns_hostnames}"
  enable_classiclink_dns_support   = "${var.enable_classiclink_dns_support}"
  tags                             = "${merge(map("Name", format("%s", local.vpc_name)), var.identifier_tags)}"
}
