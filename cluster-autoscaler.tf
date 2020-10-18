data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }
}

module "cluster_autoscaler" {
  source           = "./modules/eks-iam-role"
  enable           = var.cluster_autoscaler != null
  cluster_name     = local.cluster_name
  role_name        = "cluster-autoscaler"
  service_accounts = ["kube-system/cluster-autoscaler"]
  policies         = [data.aws_iam_policy_document.cluster_autoscaler.json]
  tags             = local.tags_map
}

resource "helm_release" "cluster_autoscaler" {
  count           = var.cluster_autoscaler != null ? 1 : 0
  name            = "cluster-autoscaler"
  repository      = local.charts_autoscaler_repo
  chart           = "cluster-autoscaler-chart"
  namespace       = "kube-system"
  version         = var.cluster_autoscaler.version
  cleanup_on_fail = true
  force_update    = false
  recreate_pods   = true

  set {
    name  = "fullnameOverride"
    value = "cluster-autoscaler"
  }

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "true"
  }

  set {
    name  = "extraArgs.expander"
    value = "least-waste"
  }

  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = "false"
  }

  set {
    name  = "extraArgs.skip-nodes-with-local-storage"
    value = "false"
  }

  set {
    name  = "priorityClassName"
    value = "system-node-critical"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cluster_autoscaler.iam_role_arn
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = local.cluster_name
  }

  set {
    name  = "autoDiscovery.tags"
    value = "kubernetes.io/cluster/${local.cluster_name}"
  }

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  dynamic "set" {
    for_each = var.cluster_autoscaler.extra_sets != null ? var.cluster_autoscaler.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
