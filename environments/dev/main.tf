data "aws_region" "current" {
  current = true
}

data "aws_caller_identity" "current" {}

#Requiring a minimum Terraform version to execute a configuration
terraform {
  required_version = "> 0.11.0"

  backend "s3" {
    bucket  = "dinocloud-terraform-cf"
    key     = "meetup/dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = "true"
    profile = "dino"
  }
}

#The provider variables for used the services
provider "aws" {
  version = "~> 1.36.0"
  profile = "dino"
  region  = "us-east-1"
}

data "null_data_source" "extra_tags" {
  inputs = {
    Environment = "${var.environment}"
    Region      = "${data.aws_region.current.name}"
    Owner       = "${var.user}"
    Team        = "${var.team}"
  }
}

locals {
  asg_tags = [{
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  },
    {
      key                 = "Region"
      value               = "${data.aws_region.current.name}"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "${var.user}"
      propagate_at_launch = true
    },
    {
      key                 = "Team"
      value               = "${var.team}"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${var.application}-${var.environment}-haproxy"
      propagate_at_launch = true
    },
  ]
}

locals {
  name_prefix = "${var.application}-${var.environment}"
}

locals {
  kub_tag = "kubernetes.io/cluster/${local.name_prefix}-eks"

  tags = {
    Environment        = "${var.environment}"
    Region             = "${data.aws_region.current.name}"
    Owner              = "${var.user}"
    Team               = "${var.team}"
    "${local.kub_tag}" = "shared"
  }
}

module "networking" {
  source             = "../../modules/networking"
  application        = "${var.application}"
  user               = "${var.user}"
  availability_zones = "${var.availability_zones}"
  vpc_cidr_block     = "${var.vpc_cidr_block}"
  team               = "${var.team}"
  subnet_size        = "${var.subnet_size}"
  subnet_assignment  = "${var.subnet_assignment}"
  environment        = "${var.environment}"
  region             = "${data.aws_region.current.name}"
  extra_tags         = "${data.null_data_source.extra_tags.inputs}"
  eks_network_tags   = "${local.tags}"
}

module "private_nlb" {
  source                           = "../../modules/aws_nlb"
  enable_cross_zone_load_balancing = true

  http_tcp_listeners = [{
    port     = 80
    protocol = "TCP"
  }]

  target_groups = [{
    name             = "${var.application}-${var.environment}-eks-nlb-tg"
    backend_protocol = "TCP"
    backend_port     = "30036"
  }]

  target_groups_count       = 1
  http_tcp_listeners_count  = 1
  load_balancer_name        = "${local.name_prefix}-eks-nlb"
  load_balancer_is_internal = true
  subnets                   = "${module.networking.application_subnets}"
  vpc_id                    = "${module.networking.vpc_id}"
  tags                      = "${local.tags}"
}


module "eks_cluster" {
  source                   = "../../modules/aws_eks_cluster"
  cluster_name             = "${var.application}-${var.environment}-eks"
  config_output_path       = "${path.cwd}/"
  subnets                  = "${module.networking.application_subnets}"
  tags                     = "${local.tags}"
  vpc_id                   = "${module.networking.vpc_id}"
  key_name                 = "${var.key_name}"
  extra_iam_policies_count = "3"
  extra_iam_policies_arn   = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"]
  attach_load_balancer     = "1"
  lb_target_group          = "${element(module.private_nlb.target_group_arns, 0)}"
  eks_ingress_port         = "30036"
  create_ingress           = true
  ingress_cidr_blocks      = ["${module.networking.application_subnet_cidrs}"]

  worker_groups = [{
    asg_desired_capacity = "2"
    asg_max_size         = "2"
    asg_min_size         = "2"
    instance_type        = "t2.medium"
  }]
}

module "heptio_ark" {
  source            = "../../modules/k8s_heptio_ark"
  application       = "${var.application}"
  environment       = "${var.environment}"
  kubeconfig_origin = "${path.cwd}/kubeconfig_${var.application}-${var.environment}-eks"
  kubeconfig_dest   = "${path.cwd}/../dr/kubeconfig_${var.application}-disaster-eks"
  dest_region       = "us-west-2"
  extra_tags        = "${data.null_data_source.extra_tags.inputs}"
}