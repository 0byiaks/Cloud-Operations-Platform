variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to repositories"
  type        = map(string)
  default     = {}
}