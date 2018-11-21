// module: aws_subnet_setup
output subnets {
  value = "${module.subnets.subnets}"
}

output subnet_ids {
  value = "${module.subnets.subnet_ids}"
}

output subnet_cidrs {
  value = "${module.subnets.subnet_cidrs}"
}

output route_table_ids {
  value = "${module.route_tables.route_table_ids}"
}
