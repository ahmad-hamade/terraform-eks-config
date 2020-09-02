resource "helm_release" "newrelic" {
  count            = var.newrelic != null ? 1 : 0
  name             = "newrelic"
  repository       = local.charts_newrelic_repo
  chart            = "nri-bundle"
  namespace        = "newrelic"
  version          = var.newrelic.version
  cleanup_on_fail  = true
  force_update     = false
  recreate_pods    = true
  create_namespace = true

  set {
    name  = "infrastructure.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.enabled"
    value = "true"
  }

  set {
    name  = "webhook.enabled"
    value = "true"
  }

  set {
    name  = "kubeEvents.enabled"
    value = "true"
  }

  set {
    name  = "logging.enabled"
    value = "false"
  }

  set {
    name  = "global.licenseKey"
    value = var.newrelic.license_key
  }

  set {
    name  = "global.cluster"
    value = local.cluster_name
  }

  dynamic "set" {
    for_each = var.newrelic.extra_sets != null ? var.newrelic.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }

  set {
    name  = "ksm.enabled"
    value = var.kube_state_metrics != null ? "false" : "true"
  }
}
