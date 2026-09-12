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

output "alb_5xx_alarm_arn" {
  description = "ARN of the ALB 5XX error alarm"
  value       = module.monitoring.alb_5xx_alarm_arn
}

output "unhealthy_host_alarm_arn" {
  description = "ARN of the unhealthy host count alarm"
  value       = module.monitoring.unhealthy_host_alarm_arn
}

output "ec2_cpu_alarm_arn" {
  description = "ARN of the EC2 CPU alarm"
  value       = module.monitoring.ec2_cpu_alarm_arn
}
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL"
  value       = module.eks.cluster_oidc_issuer
}

output "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  value       = module.eks.oidc_provider_arn
}

output "node_role_arn" {
  description = "ARN of the node IAM role"
  value       = module.eks.node_role_arn
}

output "novacorp_api_role_arn" {
  value = module.eks-platform.novacorp_api_role_arn
}