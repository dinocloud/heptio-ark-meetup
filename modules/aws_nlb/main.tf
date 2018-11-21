resource "aws_lb" "nlb" {
  load_balancer_type               = "network"
  name                             = "${var.load_balancer_name}"
  internal                         = "${var.load_balancer_is_internal}"
  subnets                          = ["${var.subnets}"]
  enable_cross_zone_load_balancing = "${var.enable_cross_zone_load_balancing}"
  enable_deletion_protection       = "${var.enable_deletion_protection}"
  ip_address_type                  = "${var.ip_address_type}"
  tags                             = "${merge(var.tags, map("Name", var.load_balancer_name))}"

  timeouts {
    create = "${var.load_balancer_create_timeout}"
    delete = "${var.load_balancer_delete_timeout}"
    update = "${var.load_balancer_update_timeout}"
  }
}

resource "aws_lb_target_group" "main" {
  name                 = "${lookup(var.target_groups[count.index], "name")}"
  vpc_id               = "${var.vpc_id}"
  port                 = "${lookup(var.target_groups[count.index], "backend_port")}"
  protocol             = "${upper(lookup(var.target_groups[count.index], "backend_protocol"))}"
  deregistration_delay = "${lookup(var.target_groups[count.index], "deregistration_delay", lookup(var.target_groups_defaults, "deregistration_delay"))}"
  target_type          = "${lookup(var.target_groups[count.index], "target_type", lookup(var.target_groups_defaults, "target_type"))}"

  health_check {
    interval = "${lookup(var.target_groups[count.index], "health_check_interval", lookup(var.target_groups_defaults, "health_check_interval"))}"

    port                = "${lookup(var.target_groups[count.index], "health_check_port", lookup(var.target_groups_defaults, "health_check_port"))}"
    healthy_threshold   = "${lookup(var.target_groups[count.index], "health_check_healthy_threshold", lookup(var.target_groups_defaults, "health_check_healthy_threshold"))}"
    unhealthy_threshold = "${lookup(var.target_groups[count.index], "health_check_unhealthy_threshold", lookup(var.target_groups_defaults, "health_check_unhealthy_threshold"))}"

    protocol = "${upper(lookup(var.target_groups[count.index], "healthcheck_protocol", lookup(var.target_groups[count.index], "backend_protocol")))}"
  }

  tags       = "${merge(var.tags, map("Name", lookup(var.target_groups[count.index], "name")))}"
  depends_on = ["aws_lb.nlb"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "frontend_http_tcp" {
  count             = "${var.http_tcp_listeners_count}"
  load_balancer_arn = "${element(concat(aws_lb.nlb.*.arn, list("")), 0)}"
  port              = "${lookup(var.http_tcp_listeners[count.index], "port")}"
  protocol          = "${lookup(var.http_tcp_listeners[count.index], "protocol")}"

  default_action {
    target_group_arn = "${aws_lb_target_group.main.*.id[lookup(var.http_tcp_listeners[count.index], "target_group_index", 0)]}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "frontend_https" {
  count             = "${var.https_listeners_count}"
  load_balancer_arn = "${element(concat(aws_lb.nlb.*.arn, list("")), 0)}"
  port              = "${lookup(var.https_listeners[count.index], "port")}"
  protocol          = "TCP"
  certificate_arn   = "${lookup(var.https_listeners[count.index], "certificate_arn")}"

  //ssl_policy        = "${lookup(var.https_listeners[count.index], "ssl_policy", var.listener_ssl_policy_default)}"

  default_action {
    target_group_arn = "${aws_lb_target_group.main.*.id[lookup(var.https_listeners[count.index], "target_group_index", 0)]}"
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "https_listener" {
  count           = "${var.extra_ssl_certs_count}"
  listener_arn    = "${aws_lb_listener.frontend_https.*.arn[lookup(var.extra_ssl_certs[count.index], "https_listener_index")]}"
  certificate_arn = "${lookup(var.extra_ssl_certs[count.index], "certificate_arn")}"
}
