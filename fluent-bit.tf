data "aws_kinesis_stream" "aws_fluent_bit_stream" {
  count = var.aws_fluent_bit != null ? 1 : 0
  name  = var.aws_fluent_bit.kinesis_stream_name
}

data "aws_iam_policy_document" "aws_fluent_bit" {
  count = var.aws_fluent_bit != null ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "kms:GenerateDataKey"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "kinesis:PutRecords"
    ]

    resources = length(data.aws_kinesis_stream.aws_fluent_bit_stream) != 0 ? data.aws_kinesis_stream.aws_fluent_bit_stream.*.arn : []
  }
}

module "aws_fluent_bit" {
  source           = "./modules/eks-iam-role"
  enable           = var.aws_fluent_bit != null
  cluster_name     = local.cluster_name
  role_name        = "aws-fluent-bit"
  service_accounts = ["kube-system/aws-fluent-bit"]
  policies         = length(data.aws_iam_policy_document.aws_fluent_bit) != 0 ? data.aws_iam_policy_document.aws_fluent_bit.*.json : []
  tags             = local.tags_map
}

resource "helm_release" "aws_fluent_bit" {
  count           = var.aws_fluent_bit != null ? 1 : 0
  name            = "aws-fluent-bit"
  repository      = local.charts_aws_repo
  chart           = "aws-for-fluent-bit"
  namespace       = "kube-system"
  version         = var.aws_fluent_bit.version
  cleanup_on_fail = true
  force_update    = false
  recreate_pods   = true

  set {
    name  = "fullnameOverride"
    value = "aws-fluent-bit"
  }

  set {
    name  = "cloudWatch.enabled"
    value = "false"
  }

  set {
    name  = "firehose.enabled"
    value = "false"
  }

  set {
    name  = "elasticsearch.enabled"
    value = "false"
  }

  set {
    name  = "kinesis.enabled"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-fluent-bit"
  }

  set {
    name  = "kinesis.region"
    value = data.aws_region.current.name
  }

  set {
    name  = "kinesis.stream"
    value = var.aws_fluent_bit.kinesis_stream_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_fluent_bit.iam_role_arn
  }

  set {
    name  = "priorityClassName"
    value = kubernetes_priority_class.high_priority_class.id
  }

  dynamic "set" {
    for_each = var.aws_fluent_bit.extra_sets != null ? var.aws_fluent_bit.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
