resource "aws_autoscaling_policy" "workers_cpu_policy" {
  name                   = "${aws_eks_cluster.this.name}_cpu_policy"
  autoscaling_group_name = "${aws_autoscaling_group.workers.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "${var.workers_scaling_up_adjustment}"
  cooldown               = "${var.workers_scaling_cooldown}"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "workers_cpu_alarm" {
  alarm_name          = "${aws_eks_cluster.this.name}_cpu_alarm"
  alarm_description   = "Alarm for EKS Cluster ${aws_eks_cluster.this.name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.workers_scaling_evaluation_period_count}"
  metric_name         = "${var.workers_scaling_metric_name}"
  namespace           = "${var.workers_scaling_metric_namespace}"
  period              = "${var.workers_scaling_evaluation_period}"
  statistic           = "${var.workers_scaling_metric_statistic}"
  threshold           = "${var.workers_scaling_up_threshold}"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.workers.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.workers_cpu_policy.arn}"]
}

# scale down alarm
resource "aws_autoscaling_policy" "workers_cpu_policy_scaledown" {
  name                   = "${aws_eks_cluster.this.name}_cpu_policy_scaledown"
  autoscaling_group_name = "${aws_autoscaling_group.workers.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "${var.workers_scaling_down_adjustment}"
  cooldown               = "${var.workers_scaling_cooldown}"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "workers_cpu_alarm_scaledown" {
  alarm_name          = "${aws_eks_cluster.this.name}_cpu_alarm_scaledown"
  alarm_description   = "Alarm for Scale Down EKS Cluster ${aws_eks_cluster.this.name}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.workers_scaling_evaluation_period_count}"
  metric_name         = "${var.workers_scaling_metric_name}"
  namespace           = "${var.workers_scaling_metric_namespace}"
  period              = "${var.workers_scaling_evaluation_period}"
  statistic           = "${var.workers_scaling_metric_statistic}"
  threshold           = "${var.workers_scaling_down_threshold}"
  datapoints_to_alarm = "${var.workers_scaling_down_datapoints}"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.workers.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.workers_cpu_policy_scaledown.arn}"]
}
