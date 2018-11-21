## module: vpc_subnet_public

output subnet_ids {
  value = ["${aws_subnet.main.*.id}"]
}

output subnet_cidrs {
  value = ["${aws_subnet.main.*.cidr_block}"]
}

output subnets {
  value = {
    id = [
      "${aws_subnet.main.*.id}",
    ]

    availability_zone = [
      "${aws_subnet.main.*.availability_zone}",
    ]

    cidr_block = [
      "${aws_subnet.main.*.cidr_block}",
    ]
  }
}
