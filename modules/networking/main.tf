module "vpc" {
  source               = "../vpc/aws_vpc"
  environment          = "${var.environment}"
  name                 = "${var.application}"
  user                 = "${var.user}"
  cidr_block           = "${var.vpc_cidr_block}"
  identifier_tags      = "${var.extra_tags}"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
}

module "internet_gateway" {
  source          = "../vpc/aws_igw"
  name            = "${var.application}"
  vpc_id          = "${module.vpc.id}"
  environment     = "${var.environment}"
  identifier_tags = "${var.extra_tags}"
}

module "nat_subnets_setup" {
  source                 = "../vpc/aws_subnet_setup"
  name                   = "${var.application}"
  gw_count               = "${length(var.availability_zones)}"
  gw_id                  = "${module.internet_gateway.igw_id}"
  vpc_id                 = "${module.vpc.id}"
  available_az           = "${var.availability_zones}"
  is_public              = "1"
  subnet_count           = "${length(var.availability_zones)}"
  user                   = "${var.user}"
  environment            = "${var.environment}"
  subnet_size            = "${var.subnet_size}"
  cidr_block             = "${module.vpc.cidr_block}"
  subnet_assignment_list = "${split(",", lookup(var.subnet_assignment, "nat", 0))}"
  subnet_type            = "nat"
  identifier_tags        = "${var.extra_tags}"
  enable_s3_vpc_endpoint = "1"
}

locals {
  name_prefix = "${var.application}-${var.environment}"
}

module "nat_gateway" {
  source         = "../vpc/aws_nat_gw"
  environment    = "${var.environment}"
  nat_subnet_ids = "${module.nat_subnets_setup.subnet_ids}"
  name           = "${local.name_prefix}-natgateway"
  ngw_count      = "${length(var.availability_zones)}"
  vpc_id         = "${module.vpc.id}"
}

module "application_subnet" {
  source                 = "../vpc/aws_subnet_setup"
  name                   = "${var.application}"
  vpc_id                 = "${module.vpc.id}"
  available_az           = "${var.availability_zones}"
  subnet_count           = "${length(var.availability_zones)}"
  user                   = "${var.user}"
  environment            = "${var.environment}"
  subnet_size            = "${var.subnet_size}"
  cidr_block             = "${module.vpc.cidr_block}"
  subnet_assignment_list = "${split(",", lookup(var.subnet_assignment, "application", 0))}"
  subnet_type            = "application"
  identifier_tags        = "${var.eks_network_tags}"
  enable_s3_vpc_endpoint = "1"
  ngw_id_list            = "${module.nat_gateway.ngw_ids}"
  is_public              = "0"
  ngw_count              = "${length(var.availability_zones)}"
}

