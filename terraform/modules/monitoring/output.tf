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