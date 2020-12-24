output "aws_vpc_cni" {
  description = "AWS VPC CNI"
  value = {
    chart_version = var.aws_vpc_cni != null ? helm_release.aws_vpc_cni[0].version : null
    iam_role_arn  = module.aws_vpc_cni.iam_role_arn
  }
}

output "cluster_autoscaler" {
  description = "Cluster autoscaler"
  value = {
    chart_version = var.cluster_autoscaler != null ? helm_release.cluster_autoscaler[0].version : null
    iam_role_arn  = module.cluster_autoscaler.iam_role_arn
  }
}

output "kube_state_metrics" {
  description = "Kube State Metrics"
  value = {
    chart_version = var.kube_state_metrics != null ? helm_release.kube_state_metrics[0].version : null
  }
}

output "kube2iam" {
  description = "Kube2IAM"
  value = {
    chart_version = var.kube2iam != null ? helm_release.kube2iam[0].version : null
  }
}

output "aws_alb_ingress_controller" {
  description = "AWS ALB Ingress Controller"
  value = {
    chart_version = var.aws_alb_ingress_controller != null ? helm_release.alb_ingress[0].version : null
    iam_role_arn  = module.alb_ingress.iam_role_arn
  }
}

output "metrics_server" {
  description = "Metrics Server"
  value = {
    chart_version = var.metrics_server != null ? helm_release.metrics_server[0].version : null
  }
}

output "aws_node_termination_handler" {
  description = "AWS Node Termination Handler"
  value = {
    chart_version = var.aws_node_termination_handler != null ? helm_release.aws_node_termination_handler[0].version : null
  }
}

output "node_problem_detector" {
  description = "Nod Problem Detector"
  value = {
    chart_version = var.node_problem_detector != null ? helm_release.node_problem_detector[0].version : null
  }
}

output "efs_provisioner" {
  description = "EFS Provisioner"
  value = {
    chart_version = var.efs_provisioner != null ? helm_release.efs_provisioner[0].version : null
  }
}

output "external_dns" {
  description = "External DNS"
  value = {
    chart_version = var.external_dns != null ? helm_release.external_dns[0].version : null
    iam_role_arn  = module.external_dns.iam_role_arn
  }
}

output "aws_fluent_bit" {
  description = "AWS Fluent-bit"
  value = {
    chart_version = var.aws_fluent_bit != null ? helm_release.aws_fluent_bit[0].version : null
    iam_role_arn  = module.aws_fluent_bit.iam_role_arn

  }
}

output "kube_downscaler" {
  description = "Kube Downscaler"
  value = {
    chart_version = var.kube_downscaler != null ? helm_release.kube_downscaler[0].version : null
  }
}

output "aws_efs_csi_driver" {
  description = "AWS EFS CSI Driver"
  value = {
    chart_version = var.aws_efs_csi_driver != null ? helm_release.aws_efs_csi_driver[0].version : null
  }
}
