variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 1
}

variable "private_subnet_app_ids" {
  description = "List of private subnet IDs for the ASG"
  type        = list(string)
}

variable "app_server_security_group_id" {
  description = "Security group ID for the EC2 instances"
  type        = string
}

variable "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for ASG notifications"
  type        = string
}