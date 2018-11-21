resource "aws_autoscaling_group" "workers" {
  name_prefix          = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups[count.index], "name", count.index)}"
  desired_capacity     = "${lookup(var.worker_groups[count.index], "asg_desired_capacity", lookup(local.workers_group_defaults, "asg_desired_capacity"))}"
  max_size             = "${lookup(var.worker_groups[count.index], "asg_max_size",lookup(local.workers_group_defaults, "asg_max_size"))}"
  min_size             = "${lookup(var.worker_groups[count.index], "asg_min_size",lookup(local.workers_group_defaults, "asg_min_size"))}"
  launch_configuration = "${element(aws_launch_configuration.workers.*.id, count.index)}"
  vpc_zone_identifier  = ["${split(",", coalesce(lookup(var.worker_groups[count.index], "subnets", ""), join(",", var.subnets)))}"]
  count                = "${var.worker_group_count}"

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${aws_eks_cluster.this.name}-${lookup(var.worker_groups[count.index], "name", count.index)}-eks_asg", "propagate_at_launch", true),
      map("key", "kubernetes.io/cluster/${aws_eks_cluster.this.name}", "value", "owned", "propagate_at_launch", true),
      map("key", "k8s.io/cluster-autoscaler/${lookup(var.worker_groups[count.index], "autoscaling_enabled", count.index) == 1 ? "enabled" : "disabled"  }", "value", "true", "propagate_at_launch", false),
    ),
    local.asg_tags)
  }"]

  lifecycle {
    ignore_changes = ["desired_capacity"]
  }
}

resource "aws_launch_configuration" "workers" {
  name_prefix                 = "${aws_eks_cluster.this.name}-${lookup(var.worker_groups[count.index], "name", count.index)}"
  associate_public_ip_address = "${lookup(var.worker_groups[count.index], "public_ip", lookup(local.workers_group_defaults, "public_ip"))}"
  security_groups             = ["${local.worker_security_group_id}", "${var.worker_additional_security_group_ids}", "${compact(split(",",lookup(var.worker_groups[count.index],"additional_security_group_ids",lookup(local.workers_group_defaults, "additional_security_group_ids"))))}"]
  iam_instance_profile        = "${aws_iam_instance_profile.workers.id}"
  image_id                    = "${lookup(var.worker_groups[count.index], "ami_id", lookup(local.workers_group_defaults, "ami_id"))}"
  instance_type               = "${lookup(var.worker_groups[count.index], "instance_type", lookup(local.workers_group_defaults, "instance_type"))}"
  key_name                    = "${lookup(var.worker_groups[count.index], "key_name", lookup(local.workers_group_defaults, "key_name"))}"
  user_data_base64            = "${base64encode(element(data.template_file.userdata.*.rendered, count.index))}"
  ebs_optimized               = "${lookup(var.worker_groups[count.index], "ebs_optimized", lookup(local.ebs_optimized, lookup(var.worker_groups[count.index], "instance_type", lookup(local.workers_group_defaults, "instance_type")), false))}"
  enable_monitoring           = "${lookup(var.worker_groups[count.index], "enable_monitoring", lookup(local.workers_group_defaults, "enable_monitoring"))}"
  spot_price                  = "${lookup(var.worker_groups[count.index], "spot_price", lookup(local.workers_group_defaults, "spot_price"))}"
  count                       = "${var.worker_group_count}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_size           = "${lookup(var.worker_groups[count.index], "root_volume_size", lookup(local.workers_group_defaults, "root_volume_size"))}"
    volume_type           = "${lookup(var.worker_groups[count.index], "root_volume_type", lookup(local.workers_group_defaults, "root_volume_type"))}"
    iops                  = "${lookup(var.worker_groups[count.index], "root_iops", lookup(local.workers_group_defaults, "root_iops"))}"
    delete_on_termination = true
  }
}

resource "aws_security_group" "workers" {
  name_prefix = "${aws_eks_cluster.this.name}"
  description = "Security group for all nodes in the cluster."
  vpc_id      = "${var.vpc_id}"
  count       = "${var.worker_security_group_id == "" ? 1 : 0}"
  tags        = "${merge(var.tags, map("Name", "${aws_eks_cluster.this.name}-eks_worker_sg", "kubernetes.io/cluster/${aws_eks_cluster.this.name}", "owned"
  ))}"
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = "${aws_security_group.workers.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
  count             = "${var.worker_security_group_id == "" ? 1 : 0}"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.workers.id}"
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
  count                    = "${var.worker_security_group_id == "" ? 1 : 0}"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers Kubelets and pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${local.cluster_security_group_id}"
  from_port                = "${var.worker_sg_ingress_from_port}"
  to_port                  = 65535
  type                     = "ingress"
  count                    = "${var.worker_security_group_id == "" ? 1 : 0}"
}

resource "aws_security_group_rule" "workers_ingress_self_cidr" {
  description       = "Allow node to communicate with each other."
  protocol          = "-1"
  security_group_id = "${aws_security_group.workers.id}"
  cidr_blocks       = ["${var.ingress_cidr_blocks}"]
  from_port         = "${var.worker_sg_ingress_from_port}"
  to_port           = 65535
  type              = "ingress"
  count             = "${var.worker_security_group_id == "" ? 1 : 0}"
}

resource "aws_iam_role" "workers" {
  name_prefix        = "${aws_eks_cluster.this.name}"
  assume_role_policy = "${data.aws_iam_policy_document.workers_assume_role_policy.json}"
}

resource "aws_iam_instance_profile" "workers" {
  name_prefix = "${aws_eks_cluster.this.name}"
  role        = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_ExtraIamPolicies" {
  count      = "${var.extra_iam_policies_count}"
  policy_arn = "${var.extra_iam_policies_arn[count.index]}"
  role       = "${aws_iam_role.workers.name}"
}

resource "null_resource" "tags_as_list_of_maps" {
  count = "${length(keys(var.tags))}"

  triggers = "${map(
    "key", "${element(keys(var.tags), count.index)}",
    "value", "${element(values(var.tags), count.index)}",
    "propagate_at_launch", "true"
  )}"
}

resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = "${aws_iam_policy.worker_autoscaling.arn}"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${aws_eks_cluster.this.name}"
  description = "EKS worker node autoscaling policy for cluster ${aws_eks_cluster.this.name}"
  policy      = "${data.aws_iam_policy_document.worker_autoscaling.json}"
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:GetAsgForInstance",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

resource "aws_autoscaling_attachment" "asg_eks_attachment" {
  count                  = "${var.attach_load_balancer}"
  autoscaling_group_name = "${aws_autoscaling_group.workers.id}"
  alb_target_group_arn   = "${var.lb_target_group}"
}
