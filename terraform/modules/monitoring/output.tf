output "alb_5xx_alarm_arn" {
  description = "ARN of the ALB 5XX error alarm"
  value       = aws_cloudwatch_metric_alarm.alb_5xx_errors.arn
}

output "unhealthy_host_alarm_arn" {
  description = "ARN of the unhealthy host count alarm"
  value       = aws_cloudwatch_metric_alarm.unhealthy_host_count.arn
}

output "ec2_cpu_alarm_arn" {
  description = "ARN of the EC2 CPU alarm"
  value       = aws_cloudwatch_metric_alarm.ec2_cpu_high.arn
}

output "nginx_access_log_group" {
  description = "CloudWatch log group for Nginx access logs"
  value       = aws_cloudwatch_log_group.nginx_access.name
}

output "nginx_error_log_group" {
  description = "CloudWatch log group for Nginx error logs"
  value       = aws_cloudwatch_log_group.nginx_error.name
}

output "ec2_system_log_group" {
  description = "CloudWatch log group for EC2 system logs"
  value       = aws_cloudwatch_log_group.ec2_system.name
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.platform_health.dashboard_name
}