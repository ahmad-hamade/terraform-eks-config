locals {
  flatList = join(",", var.service_accounts)
  replacedList = replace(
    replace(local.flatList, "/", ":"),
    "system:serviceaccount:",
    "",
  )
  serviceAccountList = formatlist("system:serviceaccount:%s", split(",", local.replacedList))
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test = "ForAnyValue:StringLike"
      variable = "${replace(
        data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer,
        "https://",
        "",
      )}:sub"
      values = local.serviceAccountList
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(
        data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer,
        "https://",
        "",
      )}"]
      type = "Federated"
    }
  }
}

resource "aws_iam_role" "role" {
  count              = var.enable ? 1 : 0
  name               = "${var.cluster_name}-${var.role_name}"
  assume_role_policy = data.aws_iam_policy_document.policy_document.json

  tags = merge(
    var.tags,
    {
      Name                                             = "${var.cluster_name}-${var.role_name}"
      "kubernetes.io/cluster/${var.cluster_name}"      = "owned"
      "kubernetes.io/cluster/${var.cluster_name}/role" = "enabled"
    }
  )
}

resource "aws_iam_role_policy" "policy" {
  count = var.enable ? length(var.policies) : 0

  name   = "${var.cluster_name}-${var.role_name}-${count.index}"
  role   = aws_iam_role.role[0].id
  policy = element(var.policies, count.index)

  lifecycle {
    create_before_destroy = true
  }
}
