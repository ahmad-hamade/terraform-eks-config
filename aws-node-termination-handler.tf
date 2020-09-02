resource "helm_release" "aws_node_termination_handler" {
  count           = var.aws_node_termination_handler != null ? 1 : 0
  name            = "aws-node-termination-handler"
  repository      = local.charts_aws_repo
  chart           = "aws-node-termination-handler"
  namespace       = "kube-system"
  version         = var.aws_node_termination_handler.version
  cleanup_on_fail = true
  force_update    = false
  recreate_pods   = true

  set {
    name  = "enableSpotInterruptionDraining"
    value = "true"
  }

  set {
    name  = "nodeSelector.lifecycle"
    value = "Ec2Spot"
  }

  set {
    name  = "enableScheduledEventDraining"
    value = "true"
  }

  set {
    name  = "priorityClassName"
    value = "system-node-critical"
  }

  dynamic "set" {
    for_each = var.aws_node_termination_handler.extra_sets != null ? var.aws_node_termination_handler.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
