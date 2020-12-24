data "aws_iam_policy_document" "alb_ingress" {
  statement {
    effect = "Allow"

    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebAcl"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "cognito-idp:DescribeUserPoolClient",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "tag:GetResources",
      "tag:TagResources"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "waf:GetWebACL"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "shield:DeleteProtection",
      "shield:CreateProtection",
      "shield:DescribeSubscription",
      "shield:ListProtections"
    ]

    resources = ["*"]
  }

}

module "alb_ingress" {
  source           = "./modules/eks-iam-role//"
  enable           = var.aws_alb_ingress_controller != null
  cluster_name     = local.cluster_name
  role_name        = "alb-ingress"
  service_accounts = ["kube-system/aws-alb-ingress-controller"]
  policies         = [data.aws_iam_policy_document.alb_ingress.json]
  tags             = local.tags_map
}

resource "helm_release" "alb_ingress" {
  count           = var.aws_alb_ingress_controller != null ? 1 : 0
  name            = "aws-alb-ingress-controller"
  repository      = local.charts_incubator_repo
  chart           = "aws-alb-ingress-controller"
  namespace       = "kube-system"
  version         = var.aws_alb_ingress_controller.version
  cleanup_on_fail = true
  force_update    = false
  recreate_pods   = true

  set {
    name  = "fullnameOverride"
    value = "aws-alb-ingress-controller"
  }

  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }

  set {
    name  = "enableReadinessProbe"
    value = "true"
  }

  set {
    name  = "enableLivenessProbe"
    value = "true"
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
    name  = "clusterName"
    value = local.cluster_name
  }

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.alb_ingress.iam_role_arn
  }

  set {
    name  = "priorityClassName"
    value = kubernetes_priority_class.high_priority_class.id
  }

  dynamic "set" {
    for_each = var.aws_alb_ingress_controller.extra_sets != null ? var.aws_alb_ingress_controller.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
