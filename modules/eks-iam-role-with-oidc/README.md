# eks-iam-role

Creates single IAM role which can be assumed by trusted resources using OpenID Connect Federated Users.

[Creating IAM OIDC Identity Providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)

This module supports IAM Roles for kubernetes service accounts as described in the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).

## Usage

Import the module and retrieve it with `terraform get`:

```terraform
module "eka_iam_role_ca" {
  source = "git@github.com:ahmad-hamade/terraform-eks-config.git//eks-iam-role?ref=TAG"

  cluster_name     = local.cluster_name
  role_name        = "cluster-autoscaler"
  service_accounts = ["kube-system/cluster-autoscaler"]
  policies         = [data.aws_iam_policy_document.cluster_autoscaler.json]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.70 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.70 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | The name of your EKS cluster | `string` | n/a | yes |
| enable | Enable/Disable resources creation | `bool` | `true` | no |
| policies | A list of all the required policies as JSON | `list(string)` | n/a | yes |
| role\_name | The name to give the new IAM role | `string` | n/a | yes |
| service\_accounts | List of Kubernetes service accounts (in the format namespace/serviceaccount) that are trusted to assume this role | `list(string)` | n/a | yes |
| tags | Tags to be applied to all resources created for the AWS resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| iam\_role\_arn | IAM Role ARN |
| iam\_role\_name | IAM Role name |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
