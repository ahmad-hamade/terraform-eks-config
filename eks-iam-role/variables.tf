variable "enable" {
  type        = bool
  description = "Enable/Disable resources creation"
}

variable "cluster_name" {
  type        = string
  description = "The name of your EKS cluster"
}

variable "role_name" {
  type        = string
  description = "The name to give the new IAM role"
}

variable "policies" {
  type        = list(string)
  description = "A list of all the required policies as JSON"
}

variable "service_accounts" {
  type        = list(string)
  description = "Array of Kubernetes service accounts (in the format namespace/serviceaccount) that are trusted to assume this role"
}

variable "tags" {
  description = "Tags to be applied to all resources created for the AWS resources"
  type        = map(string)
}
