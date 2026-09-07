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

variable "github_org_id" {
  description = "Immutable numeric GitHub org/user ID (see: gh api repos/OWNER/REPO/actions/oidc/customization/sub)"
  type        = string
  default     = "110993470"
}

variable "github_repo_id" {
  description = "Immutable numeric GitHub repo ID (see: gh api repos/OWNER/REPO/actions/oidc/customization/sub)"
  type        = string
  default     = "1349535033"
}