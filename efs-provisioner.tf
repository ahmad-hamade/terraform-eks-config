resource "helm_release" "efs_provisioner" {
  count           = var.efs_provisioner != null ? 1 : 0
  name            = "efs-provisioner"
  repository      = local.charts_stable_repo
  chart           = "efs-provisioner"
  namespace       = "kube-system"
  version         = var.efs_provisioner.version
  cleanup_on_fail = true
  force_update    = false
  recreate_pods   = true

  set {
    name  = "global.deployEnv"
    value = "infra"
  }

  set {
    name  = "efsProvisioner.path"
    value = "/"
  }

  set {
    name  = "efsProvisioner.provisionerName"
    value = "aws.io/aws-efs"
  }

  set {
    name  = "efsProvisioner.awsRegion"
    value = data.aws_region.current.name
  }

  set {
    name  = "efsProvisioner.efsFileSystemId"
    value = var.efs_provisioner.fs_id
  }

  set {
    name  = "priorityClassName"
    value = kubernetes_priority_class.high_priority_class.id
  }

  dynamic "set" {
    for_each = var.efs_provisioner.extra_sets != null ? var.efs_provisioner.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
