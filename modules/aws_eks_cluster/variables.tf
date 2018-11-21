variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
}

variable "cluster_security_group_id" {
  description = "If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the workers and provide API access to your current IP/32."
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  default     = "1.10"
}

variable "config_output_path" {
  description = "Determines where config files are placed if using configure_kubectl_session and you want config files to land outside the current working directory. Should end in a forward slash / ."
  default     = "./"
}

variable "write_kubeconfig" {
  description = "Whether to write a kubeconfig file containing the cluster configuration."
  default     = true
}

variable "write_mandatory" {
  description = "Whether to write a kubeconfig file containing the cluster configuration."
  default     = true
}

variable "write_service_l4" {
  description = "Whether to write a kubeconfig file containing the cluster configuration."
  default     = true
}

variable "write_patch_configmap_l4" {
  description = "Whether to write a kubeconfig file containing the cluster configuration."
  default     = true
}

variable "write_external_dns" {
  description = "Whether to write a kubeconfig file containing the cluster configuration."
  default     = true
}

variable "provisioning" {
  description = "Whether to write a kubeconfig file containing the cluster configuration."
  default     = true
}

variable "create_elb_service_linked_role" {
  description = "Whether to create the service linked role for the elasticloadbalancing service. Without this EKS cannot create ELBs."
  default     = false
}

variable "manage_aws_auth" {
  description = "Whether to write and apply the aws-auth configmap file."
  default     = true
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format."
  type        = "list"
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format."
  type        = "list"
  default     = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See examples/eks_test_fixture/variables.tf for example format."
  type        = "list"
  default     = []
}

variable "create_ingress" {
  description = "Create ingress controller at a specified port."
  default     = true
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = "list"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = "map"
  default     = {}
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
}

variable "worker_groups" {
  description = "A list of maps defining worker group configurations. See workers_group_defaults for valid keys."
  type        = "list"

  default = [{
    "name" = "default"
  }]
}

variable "worker_group_count" {
  description = "The number of maps contained within the worker_groups list."
  type        = "string"
  default     = "1"
}

variable "workers_group_defaults" {
  description = "Override default values for target groups. See workers_group_defaults_defaults in locals.tf for valid keys."
  type        = "map"
  default     = {}
}

variable "worker_security_group_id" {
  description = "If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the EKS cluster."
  default     = ""
}

variable "worker_additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances"
  type        = "list"
  default     = []
}

variable "worker_sg_ingress_from_port" {
  description = "Minimum port number from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443)."
  default     = "1025"
}

variable "workers_scaling_up_adjustment" {
  description = "Count of workers to add in each scaling event"
  default     = "1"
}

variable "workers_scaling_down_adjustment" {
  description = "Count of workers to add in each scaling event"
  default     = "-1"
}

variable "workers_scaling_cooldown" {
  description = "Cooldown for workers scaling events"
  default     = "300"
}

variable "workers_scaling_metric_name" {
  description = "Metric to take in mind for workers scaling"
  default     = "CPUUtilization"
}

variable "workers_scaling_metric_namespace" {
  description = "Metric namespace to take in mind for workers scaling"
  default     = "AWS/EC2"
}

variable "workers_scaling_metric_statistic" {
  description = "Metric statistic to take in mind for workers scaling"
  default     = "Average"
}

variable "workers_scaling_evaluation_period" {
  description = "Evaluation period in seconds for workers scaling"
  default     = "60"
}

variable "workers_scaling_down_datapoints" {
  description = "The number of datapoints that must be breaching to trigger the alarm"
  default     = "8"
}

variable "workers_scaling_evaluation_period_count" {
  description = "Evaluation periods count for workers scaling"
  default     = "10"
}

variable "workers_scaling_up_threshold" {
  description = "Threshold to trigger a scaling up event in workers"
  default     = "50"
}

variable "workers_scaling_down_threshold" {
  description = "Threshold to trigger a scaling down event in workers"
  default     = "15"
}

variable "kubeconfig_aws_authenticator_command" {
  description = "Command to use to to fetch AWS EKS credentials."
  default     = "aws-iam-authenticator"
}

variable "kubeconfig_aws_authenticator_additional_args" {
  description = "Any additional arguments to pass to the authenticator such as the role to assume. e.g. [\"-r\", \"MyEksRole\"]."
  type        = "list"
  default     = []
}

variable "kubeconfig_aws_authenticator_env_variables" {
  description = "Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = \"eks\"}."
  type        = "map"
  default     = {}
}

variable "kubeconfig_name" {
  description = "Override the default name used for items kubeconfig."
  default     = ""
}

variable "key_name" {
  default = ""
}

variable "extra_iam_policies_count" {
  default = "0"
}

variable "extra_iam_policies_arn" {
  type    = "list"
  default = []
}

variable "eks_ingress_port" {
  default = "30036"
}

variable "attach_load_balancer" {
  default = "0"
}

variable "lb_target_group" {
  default = ""
}

variable "ingress_cidr_blocks" {
  type    = "list"
  default = []
}
