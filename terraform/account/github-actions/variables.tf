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

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  default     = "716769866080"
}

variable "github_org" {
  description = "GitHub organisation or username"
  type        = string
  default     = "0byiaks"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "Cloud-Operations-Platform"
}