resource "helm_release" "kube_state_metrics" {
  count         = var.kube_state_metrics != null ? 1 : 0
  name          = "kube-state-metrics"
  repository    = "https://kubernetes.github.io/kube-state-metrics"
  chart         = "kube-state-metrics"
  namespace     = "kube-system"
  version       = var.kube_state_metrics.version
  force_update  = true
  recreate_pods = true

  set {
    name  = "nameOverride"
    value = "kube-state-metrics"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "priorityClassName"
    value = kubernetes_priority_class.high_priority_class.id
  }

  dynamic "set" {
    for_each = var.kube_state_metrics.extra_sets != null ? var.kube_state_metrics.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
