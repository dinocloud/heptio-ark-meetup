module "aws_eip" {
  source    = "../aws_eip"
  eip_count = "${var.ngw_count}"
}

data "null_data_source" "igw_tags" {
  inputs = {
    Environment = "${var.environment}"
    Name        = "${var.environment}-${var.name}-nat-gw"
    Region      = "${data.aws_region.current.name}"
  }
}

data "aws_region" "current" {
  current = true
}

## Bug: COUNT DYNAMIC

## it is a static look up right now to switch between 3 (when private subnet is used, therefore nat gateways are required),
##  0 (when private subnets are not used,  therefore no nat required)
## This is likely related to https://github.com/hashicorp/terraform/issues/1497, more importantly https://github.com/hashicorp/terraform/issues/3888

resource "aws_nat_gateway" "ngw" {
  count         = "${var.ngw_count}"
  subnet_id     = "${element(var.nat_subnet_ids, count.index)}"
  allocation_id = "${element(module.aws_eip.eip_alloc_id, count.index)}"
  tags          = "${merge(var.identifier_tags, data.null_data_source.igw_tags.inputs)}"
}
