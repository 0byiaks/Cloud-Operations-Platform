variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cop"
}

variable "iam_user_name" {
  description = "Name of the IAM user for Terraform operations"
  type        = string
  default     = "cop-terraform-user"
}