variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "VPC ID to deploy the cluster into"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for worker nodes"
  type        = list(string)
}

variable "app_node_instance_type" {
  description = "Instance type for app node group"
  type        = string
  default     = "t3.medium"
}

variable "platform_node_instance_type" {
  description = "Instance type for platform node group"
  type        = string
  default     = "t3.medium"
}

variable "app_node_min" {
  description = "Minimum nodes in app node group"
  type        = number
  default     = 1
}

variable "app_node_max" {
  description = "Maximum nodes in app node group"
  type        = number
  default     = 3
}

variable "app_node_desired" {
  description = "Desired nodes in app node group"
  type        = number
  default     = 2
}

variable "platform_node_min" {
  description = "Minimum nodes in platform node group"
  type        = number
  default     = 1
}

variable "platform_node_max" {
  description = "Maximum nodes in platform node group"
  type        = number
  default     = 2
}

variable "platform_node_desired" {
  description = "Desired nodes in platform node group"
  type        = number
  default     = 1
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}