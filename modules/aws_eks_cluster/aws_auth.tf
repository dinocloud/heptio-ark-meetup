resource "local_file" "config_map_aws_auth" {
  content  = "${data.template_file.config_map_aws_auth.rendered}"
  filename = "${var.config_output_path}config-map-aws-auth_${var.cluster_name}.yaml"
  count    = "${var.manage_aws_auth ? 1 : 0}"
}

resource "local_file" "ingress_nginx" {
  content  = "${data.template_file.ingress_nginx.rendered}"
  filename = "${var.config_output_path}ingress-nginx_${var.cluster_name}.yaml"
  count    = "${var.create_ingress ? 1 : 0}"
}

resource "null_resource" "update_config_map_aws_auth" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${var.config_output_path}config-map-aws-auth_${var.cluster_name}.yaml --kubeconfig ${var.config_output_path}kubeconfig_${var.cluster_name}"
  }

  triggers {
    config_map_rendered = "${data.template_file.config_map_aws_auth.rendered}"
  }

  count = "${var.manage_aws_auth ? 1 : 0}"
}

//resource "null_resource" "update_nginx_ingress" {
//  depends_on = ["null_resource.update_config_map_aws_auth"]
//  provisioner "local-exec" {
//    command = "kubectl apply -f ${var.config_output_path}ingress-nginx_${var.cluster_name}.yaml --kubeconfig ${var.config_output_path}kubeconfig_${var.cluster_name}"
//  }
//
//  triggers {
//    config_map_rendered = "${data.template_file.ingress_nginx.rendered}"
//  }
//
//  count = "${var.create_ingress ? 1 : 0}"
//}

data "template_file" "config_map_aws_auth" {
  template = "${file("${path.module}/templates/config-map-aws-auth.yaml.tpl")}"

  vars {
    worker_role_arn = "${aws_iam_role.workers.arn}"
    map_users       = "${join("", data.template_file.map_users.*.rendered)}"
    map_roles       = "${join("", data.template_file.map_roles.*.rendered)}"
    map_accounts    = "${join("", data.template_file.map_accounts.*.rendered)}"
  }
}

data "template_file" "map_users" {
  count    = "${length(var.map_users)}"
  template = "${file("${path.module}/templates/config-map-aws-auth-map_users.yaml.tpl")}"

  vars {
    user_arn = "${lookup(var.map_users[count.index], "user_arn")}"
    username = "${lookup(var.map_users[count.index], "username")}"
    group    = "${lookup(var.map_users[count.index], "group")}"
  }
}

data "template_file" "map_roles" {
  count    = "${length(var.map_roles)}"
  template = "${file("${path.module}/templates/config-map-aws-auth-map_roles.yaml.tpl")}"

  vars {
    role_arn = "${lookup(var.map_roles[count.index], "role_arn")}"
    username = "${lookup(var.map_roles[count.index], "username")}"
    group    = "${lookup(var.map_roles[count.index], "group")}"
  }
}

data "template_file" "map_accounts" {
  count    = "${length(var.map_accounts)}"
  template = "${file("${path.module}/templates/config-map-aws-auth-map_accounts.yaml.tpl")}"

  vars {
    account_number = "${element(var.map_accounts, count.index)}"
  }
}

data "template_file" "ingress_nginx" {
  count    = "${var.create_ingress ? 1 : 0}"
  template = "${file("${path.module}/templates/ingress.yaml.tpl")}"

  vars {
    eks_port = "${var.eks_ingress_port}"
  }
}
