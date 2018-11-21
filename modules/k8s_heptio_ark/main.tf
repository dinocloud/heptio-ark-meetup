data "aws_region" "current" {}

data "template_file" "ark_config_yaml" {
  template = "${file("${path.module}/files/00-ark-config.yaml.tpl")}"

  vars {
    aws_region           = "${data.aws_region.current.name}"
    heptio_bucket_region = "${data.aws_region.current.name}"
    heptio_bucket_name   = "${module.heptio_s3_bucket.ids}"
  }
}

data "template_file" "ark_config_dest_yaml" {
  template = "${file("${path.module}/files/00-ark-config-dest.yaml.tpl")}"

  vars {
    aws_region           = "${var.dest_region}"
    heptio_bucket_region = "${data.aws_region.current.name}"
    heptio_bucket_name   = "${module.heptio_s3_bucket.ids}"
  }
}

resource "local_file" "ark_config_yaml" {
  content  = "${data.template_file.ark_config_yaml.rendered}"
  filename = "${path.module}/files/00-ark-config.yaml"
}

resource "local_file" "ark_config_dest_yaml" {
  content  = "${data.template_file.ark_config_dest_yaml.rendered}"
  filename = "${path.module}/files/00-ark-config-dest.yaml"
}

resource "null_resource" "apply_heptio_servers" {
  provisioner "local-exec" {
    command     = "./provision_heptio_server.sh"
    working_dir = "${path.module}/files"

    environment {
      KUBECONFIG_ORIG = "${var.kubeconfig_origin}"
      KUBECONFIG_DEST = "${var.kubeconfig_dest}"
    }
  }

  depends_on = ["local_file.ark_config_yaml", "local_file.ark_config_dest_yaml"]

  triggers {
    ark_config_rendered      = "${data.template_file.ark_config_yaml.rendered}"
    ark_config_dest_rendered = "${data.template_file.ark_config_dest_yaml.rendered}"
  }
}

module "heptio_s3_bucket" {
  source      = "../aws_s3_bucket"
  bucket_name = "${var.application}-${var.environment}-heptio-${data.aws_region.current.name}"
  tags        = "${var.extra_tags}"
  versioned   = true
}

