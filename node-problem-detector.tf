resource "helm_release" "node_problem_detector" {
  count           = var.node_problem_detector != null ? 1 : 0
  name            = "node-problem-detector"
  repository      = "https://charts.deliveryhero.io/"
  chart           = "node-problem-detector"
  namespace       = "kube-system"
  version         = var.node_problem_detector.version
  cleanup_on_fail = true
  force_update    = false
  recreate_pods   = true

  set {
    name  = "fullnameOverride"
    value = "node-problem-detector"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "priorityClassName"
    value = kubernetes_priority_class.medium_priority_class.id
  }

  dynamic "set" {
    for_each = var.node_problem_detector.extra_sets != null ? var.node_problem_detector.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
