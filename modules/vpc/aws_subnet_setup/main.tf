module "subnets" {
  source       = "../aws_subnet"
  name         = "${var.name}"
  vpc_id       = "${var.vpc_id}"
  available_az = "${var.available_az}"

  #user         = "${var.user}"
  environment = "${var.environment}"
  subnet_size = "${var.subnet_size}"
  cidr_block  = "${var.cidr_block}"
  is_public   = "${var.is_public}"

  //  subnet_type       = "service"
  subnet_type       = "${var.subnet_type}"
  subnet_count      = "${var.subnet_count}"
  subnet_assignment = "${var.subnet_assignment_list}"
  tag_values        = "${var.subnet_tag_values}"
  identifier_tags   = "${var.identifier_tags}"
}

module "route_tables" {
  source                       = "../aws_route_table"
  vpc_id                       = "${var.vpc_id}"
  available_az                 = "${var.available_az}"
  cluster_name                 = "${var.user} - ${var.environment}"
  route_table_count            = "${var.subnet_count}"
  purpose                      = "${var.subnet_type}"
  propagating_vgws             = "${var.propagating_vgws}"
  identifier_tags              = "${var.identifier_tags}"
  s3_vpc_endpoint_id           = "${var.s3_vpc_endpoint_id}"
  enable_s3_vpc_endpoint       = "${var.enable_s3_vpc_endpoint}"
  dynamodb_vpc_endpoint_id     = "${var.dynamodb_vpc_endpoint_id}"
  enable_dynamodb_vpc_endpoint = "${var.enable_dynamodb_vpc_endpoint}"
}

module "route_ngw" {
  source          = "../aws_route"
  route_table_ids = "${module.route_tables.route_table_ids}"
  dst_cidr_block  = "${var.dst_cidr_block}"
  ngw_count       = "${var.ngw_count}"
  ngw_id_list     = "${var.ngw_id_list}"
}

module "route_igw" {
  source          = "../aws_route"
  route_table_ids = "${module.route_tables.route_table_ids}"
  dst_cidr_block  = "${var.dst_cidr_block}"
  gw_count        = "${var.gw_count}"
  gw_id_list      = ["${var.gw_id}"]
}

module "route_to_ops" {
  source            = "../aws_route"
  route_table_ids   = "${module.route_tables.route_table_ids}"
  dst_cidr_block    = "${var.ops_cidr}"
  vpc_peering_count = "${var.enable_ops_peering_routes}"
  vpc_peering_id    = "${var.ops_peering_id}"
}

resource "aws_route_table_association" "route_private_ngw" {
  count          = "${var.ngw_count}"
  subnet_id      = "${element(module.subnets.subnet_ids, count.index)}"
  route_table_id = "${element(module.route_tables.route_table_ids, count.index)}"
}

resource "aws_route_table_association" "route_public_igw" {
  count          = "${var.gw_count}"
  subnet_id      = "${element(module.subnets.subnet_ids, count.index)}"
  route_table_id = "${element(module.route_tables.route_table_ids, count.index)}"
}
