# The below workaround is to solve certificate signed by unknown authority https://github.com/kubernetes-sigs/metrics-server/issues/443
resource "kubernetes_cluster_role_binding" "kubelet_api_admin" {
  count = var.metrics_server != null ? 1 : 0
  metadata {
    name = "kubelet-api-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:kubelet-api-admin"
  }

  subject {
    kind      = "User"
    name      = "kubelet-api"
    api_group = "rbac.authorization.k8s.io"
    namespace = ""
  }
}

resource "helm_release" "metrics_server" {
  count           = var.metrics_server != null ? 1 : 0
  name            = "metrics-server"
  repository      = local.charts_stable_repo
  chart           = "metrics-server"
  namespace       = "kube-system"
  version         = var.metrics_server.version
  cleanup_on_fail = true
  force_update    = false
  recreate_pods   = true

  set {
    name  = "nameOverride"
    value = "metrics-server"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "args"
    value = "{--v=2,--kubelet-preferred-address-types=InternalIP,--kubelet-insecure-tls}"
  }

  set {
    name  = "priorityClassName"
    value = kubernetes_priority_class.high_priority_class.id
  }

  dynamic "set" {
    for_each = var.metrics_server.extra_sets != null ? var.metrics_server.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
