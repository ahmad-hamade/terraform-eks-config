output "iam_role_name" {
  description = "IAM Role name"
  value       = join("", aws_iam_role.role.*.name)
}

output "iam_role_arn" {
  description = "IAM Role ARN"
  value       = join("", aws_iam_role.role.*.arn)
}
