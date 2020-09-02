resource "helm_release" "kube2iam" {
  count           = var.kube2iam != null ? 1 : 0
  name            = "kube2iam"
  repository      = local.charts_stable_repo
  chart           = "kube2iam"
  namespace       = "kube-system"
  version         = var.kube2iam.version
  cleanup_on_fail = true
  force_update    = false
  recreate_pods   = true

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccountName"
    value = "kube2iam"
  }

  set {
    name  = "extraArgs.auto-discover-base-arn"
    value = ""
  }

  set {
    name  = "extraArgs.use-regional-sts-endpoint"
    value = ""
  }

  set {
    name  = "extraArgs.auto-discover-default-role"
    value = ""
  }

  set {
    name  = "log-level"
    value = "info"
  }

  set {
    name  = "host.iptables"
    value = "true"
  }

  set {
    name  = "host.interface"
    value = "eni+"
  }

  set {
    name  = "priorityClassName"
    value = "system-node-critical"
  }

  set {
    name  = "aws.region"
    value = data.aws_region.current.name
  }

  dynamic "set" {
    for_each = var.kube2iam.extra_sets != null ? var.kube2iam.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
