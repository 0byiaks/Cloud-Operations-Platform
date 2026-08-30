output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = module.alb.alb_arn
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.asg.asg_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = module.route53.sns_topic_arn
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = module.asg.launch_template_id
}