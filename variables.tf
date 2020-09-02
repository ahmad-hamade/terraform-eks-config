variable "cluster_name" {
  description = "EKS Cluster name to install the services"
  type        = string
}

variable "priority_class_mames" {
  description = "The name of default priority class to be created in the EKS cluster"
  type = object({
    high_priority   = string
    medium_priority = string
    low_priority    = string
  })
  default = {
    high_priority   = "high-priority"
    medium_priority = "medium-priority"
    low_priority    = "low-priority"
  }
}

variable "aws_auth" {
  description = "AWS configuration for cluster authentication"
  type = object({
    nodes_role_arn  = string
    admin_iam_roles = list(string)
  })
  default = null
}

variable "aws_vpc_cni" {
  description = "Installs the AWS CNI Daemonset"
  type = object({
    version    = string
    extra_sets = map(string)
  })
  default = null
}

variable "kube_downscaler" {
  description = "Scale down Kubernetes deployments and/or statefulsets during non-work hours"
  type = object({
    version    = string
    extra_sets = map(string)
  })
  default = null
}

variable "cluster_autoscaler" {
  description = "Cluster autoscaler configuration"
  type = object({
    version    = string
    extra_sets = map(string)
  })
  default = null
}

variable "kube2iam" {
  description = "kube2iam"
  type = object({
    version    = string
    extra_sets = map(string)
  })
  default = null
}

variable "aws_alb_ingress_controller" {
  description = "ALB ingress configuration"
  type = object({
    version    = string
    extra_sets = map(string)
  })
  default = null
}

variable "metrics_server" {
  description = "Resource metrics are used by components like kubectl top and the HPA"
  type = object({
    version    = string
    extra_sets = map(string)
  })
  default = null
}

variable "kube_state_metrics" {
  description = "Kube State Metrics"
  type = object({
    version    = string
    extra_sets = map(string)
  })
  default = null
}

variable "aws_node_termination_handler" {
  description = "AWS Node Termination Handler"
  type = object({
    version    = string
    extra_sets = map(string)
  })
  default = null
}

variable "node_problem_detector" {
  description = "Make various node problems visible to the upstream layers in cluster management stack"
  type = object({
    version    = string
    extra_sets = map(string)
  })
  default = null
}

variable "efs_provisioner" {
  description = "EFS Provisioner"
  type = object({
    version    = string
    fs_id      = string
    extra_sets = map(string)
  })
  default = null
}

variable "newrelic" {
  description = "Newrelic nri-bundle"
  type = object({
    version     = string
    license_key = string
    extra_sets  = map(string)
  })
  default = null
}

variable "external_dns" {
  description = "Configures public DNS servers with information about exposed Kubernetes services"
  type = object({
    version          = string
    route53_zone_ids = list(string)
    extra_sets       = map(string)
  })
  default = null
}

variable "aws_efs_csi_driver" {
  description = "Amazon Elastic File System Container Storage Interface (CSI) Driver"
  type = object({
    version    = string
    extra_sets = map(string)
  })
  default = null
}

variable "aws_fluent_bit" {
  description = "AWS Fluentbit"
  type = object({
    version             = string
    kinesis_stream_name = string
    extra_sets          = map(string)
  })
  default = null
}

#--------------------------------------------------------------
# Tagging Variables
#--------------------------------------------------------------

variable "tags" {
  description = "Additional tags to be applied to all resources created for the AWS resources"
  type        = map(string)
  default     = {}
}
