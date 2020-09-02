resource "kubernetes_storage_class" "aws_efs_csi_driver" {
  count = var.aws_efs_csi_driver != null ? 1 : 0
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  mount_options       = ["tls"]

  depends_on = [helm_release.aws_efs_csi_driver]
}

resource "helm_release" "aws_efs_csi_driver" {
  count           = var.aws_efs_csi_driver != null ? 1 : 0
  name            = "aws-efs-csi-driver"
  repository      = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart           = "aws-efs-csi-driver"
  namespace       = "kube-system"
  version         = var.aws_efs_csi_driver.version
  cleanup_on_fail = true
  force_update    = false
  recreate_pods   = true

  dynamic "set" {
    for_each = var.aws_efs_csi_driver.extra_sets != null ? var.aws_efs_csi_driver.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
