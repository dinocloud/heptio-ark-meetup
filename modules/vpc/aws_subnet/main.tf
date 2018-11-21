## module: aws_subnet_public

data "template_file" "subnet_offset_to_assigned_size" {
  template = "$${val}"

  vars {
    val = "${var.subnet_size - element(split("/",var.cidr_block), 1)}"
  }
}

data "template_file" "_subnet_name" {
  count = "${var.number_of_az}"

  template = "$${name}-$${subnet_type}-$${az}"

  vars {
    name        = "${var.name}"
    subnet_type = "${var.subnet_type}"
    az          = "${element(var.available_az, count.index)}"
  }
}

resource "aws_subnet" "main" {
  count = "${var.subnet_count * var.enable_subnet}"

  availability_zone = "${element(var.available_az, count.index)}"
  cidr_block        = "${cidrsubnet(var.cidr_block, data.template_file.subnet_offset_to_assigned_size.rendered, element( var.subnet_assignment, count.index ))}"
  vpc_id            = "${var.vpc_id}"

  map_public_ip_on_launch = "${var.is_public}"

  tags = "${merge(map("Name", element(data.template_file._subnet_name.*.rendered, count.index)),var.tag_values, var.identifier_tags) }"
}
