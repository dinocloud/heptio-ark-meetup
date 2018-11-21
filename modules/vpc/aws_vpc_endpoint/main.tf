# module: aws_vpc_endpoint

resource "aws_vpc_endpoint" "vpc_endpoint" {
  count        = "${var.enable_vpc_endpoint}"
  vpc_id       = "${var.vpc_id}"
  service_name = "${var.service}"
}
