resource "helm_release" "kube_downscaler" {
  count           = var.kube_downscaler != null ? 1 : 0
  name            = "kube-downscaler"
  repository      = local.charts_incubator_repo
  chart           = "kube-downscaler"
  namespace       = "kube-system"
  version         = var.kube_downscaler.version
  cleanup_on_fail = true
  force_update    = false
  recreate_pods   = true

  set {
    name  = "fullnameOverride"
    value = "kube-downscaler"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  dynamic "set" {
    for_each = var.kube_downscaler.extra_sets != null ? var.kube_downscaler.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
