variable "aws_region" {
  description = "AWS region"
  type        = string
  
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  
}

variable "environment" {
  description = "Environment name"
  type        = string
  
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  
}
variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  
}

variable "domain_name" {
  description = "Root domain name"
  type        = string
}

variable "public_subnet_az1_cidr" {
  description = "Public subnet AZ1 CIDR"
  type        = string
}

variable "public_subnet_az2_cidr" {
  description = "Public subnet AZ2 CIDR"
  type        = string
}

variable "private_subnet_app_az1_cidr" {
  description = "Private app subnet AZ1 CIDR"
  type        = string
}

variable "private_subnet_app_az2_cidr" {
  description = "Private app subnet AZ2 CIDR"
  type        = string
}

variable "private_subnet_data_az1_cidr" {
  description = "Private data subnet AZ1 CIDR"
  type        = string
}

variable "private_subnet_data_az2_cidr" {
  description = "Private data subnet AZ2 CIDR"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  
}

variable "asg_min_size" {
  description = "ASG minimum instance count"
  type        = number
  
}

variable "asg_max_size" {
  description = "ASG maximum instance count"
  type        = number
  
}

variable "asg_desired" {
  description = "ASG desired instance count"
  type        = number
 
}

variable "load_balancer_type" {
  description = "Load balancer type"
  type        = string
  
}

variable "target_type" {
  description = "Target type"
  type        = string
  
}   

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "operator_email" {
  description = "Operator email"
  type        = string
  
}