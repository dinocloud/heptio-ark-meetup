output "application_subnets" {
  value = "${module.application_subnet.subnet_ids}"
}

output "application_subnet_cidrs" {
  value = "${module.application_subnet.subnet_cidrs}"
}
output "public_subnets" {
  value = "${module.nat_subnets_setup.subnet_ids}"
}

output "vpc_id" {
  value = "${module.vpc.id}"
}