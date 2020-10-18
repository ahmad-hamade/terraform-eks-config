output "iam_role_arn" {
  value = join("", aws_iam_role.role.*.arn)
}

output "iam_role_name" {
  value = join("", aws_iam_role.role.*.name)
}
