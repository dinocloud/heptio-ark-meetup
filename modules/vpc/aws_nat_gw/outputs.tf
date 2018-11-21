## module: vpc_nat_gw

output ngw_ids {
  value = ["${aws_nat_gateway.ngw.*.id}"]
}

output ngws {
  value = {
    id         = ["${aws_nat_gateway.ngw.*.id}"]
    subnet_id  = ["${aws_nat_gateway.ngw.*.subnet_id}"]
    private_ip = ["${aws_nat_gateway.ngw.*.private_ip}"]
    public_ip  = ["${aws_nat_gateway.ngw.*.public_ip}"]
  }
}
