# module: aws_vpc_endpoint

output "vpc_endpoint_id" {
  value = "${aws_vpc_endpoint.vpc_endpoint.id}"
}

output "vpc_endpoint_prefix_list_id" {
  value = ["${aws_vpc_endpoint.vpc_endpoint.prefix_list_id}"]
}

output "vpc_endpoint_cidr_blocks" {
  value = ["${aws_vpc_endpoint.vpc_endpoint.cidr_blocks}"]
}
