data "aws_route53_zone" "external_dns" {
  count   = var.external_dns != null ? length(var.external_dns.route53_zone_ids) : 0
  zone_id = var.external_dns.route53_zone_ids[count.index]
}

data "aws_iam_policy_document" "external_dns" {
  count = var.external_dns != null ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = formatlist("arn:aws:route53:::hostedzone/%s", var.external_dns.route53_zone_ids)
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]

    resources = ["*"]
  }
}

module "external_dns" {
  source           = "./modules/eks-iam-role//"
  enable           = var.external_dns != null
  cluster_name     = local.cluster_name
  role_name        = "external-dns"
  service_accounts = ["kube-system/external-dns"]
  policies         = length(data.aws_iam_policy_document.external_dns) != 0 ? data.aws_iam_policy_document.external_dns.*.json : []
  tags             = local.tags_map
}

resource "helm_release" "external_dns" {
  count           = var.external_dns != null ? 1 : 0
  name            = "external-dns"
  repository      = local.charts_bitnami_repo
  chart           = "external-dns"
  namespace       = "kube-system"
  version         = var.external_dns.version
  cleanup_on_fail = true
  force_update    = false
  recreate_pods   = true

  set {
    name  = "fullnameOverride"
    value = "external-dns"
  }

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.pspEnabled"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.external_dns.iam_role_arn
  }

  set {
    name  = "priorityClassName"
    value = kubernetes_priority_class.high_priority_class.id
  }

  set {
    name  = "aws.region"
    value = data.aws_region.current.name
  }

  set {
    name  = "domainFilters"
    value = "{${join(",", data.aws_route53_zone.external_dns.*.name)}}"
  }

  dynamic "set" {
    for_each = var.external_dns.extra_sets != null ? var.external_dns.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
