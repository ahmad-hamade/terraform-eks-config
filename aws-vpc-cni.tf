module "aws_vpc_cni" {
  source           = "./eks-iam-role//"
  enable           = var.aws_vpc_cni != null
  cluster_name     = local.cluster_name
  role_name        = "aws-vpc-cni"
  service_accounts = ["kube-system/aws-vpc-cni"]
  policies         = []
  tags             = local.tags_map
}

resource "aws_iam_role_policy_attachment" "aws_vpc_cni" {
  count      = var.aws_vpc_cni != null ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = module.aws_vpc_cni.iam_role_name
}

resource "helm_release" "aws_vpc_cni" {
  count           = var.aws_vpc_cni != null ? 1 : 0
  name            = "aws-vpc-cni"
  repository      = "https://aws.github.io/eks-charts/"
  chart           = "aws-vpc-cni"
  namespace       = "kube-system"
  version         = var.aws_vpc_cni.version
  cleanup_on_fail = true
  force_update    = false
  recreate_pods   = true

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-vpc-cni"
  }

  set {
    name  = "image.region"
    value = data.aws_region.current.name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_vpc_cni.iam_role_arn
  }

  dynamic "set" {
    for_each = var.aws_vpc_cni.extra_sets != null ? var.aws_vpc_cni.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [aws_iam_role_policy_attachment.aws_vpc_cni]
}
