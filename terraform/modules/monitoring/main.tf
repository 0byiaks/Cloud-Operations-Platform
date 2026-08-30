# ALB 5XX error rate alarm
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.environment}-${var.project_name}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB is returning 5XX errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Unhealthy host count alarm
resource "aws_cloudwatch_metric_alarm" "unhealthy_host_count" {
  alarm_name          = "${var.environment}-${var.project_name}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "One or more targets are unhealthy"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# EC2 CPU utilisation alarm
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "${var.environment}-${var.project_name}-ec2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2 CPU utilisation is above 80%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Log groups for Nginx logs
resource "aws_cloudwatch_log_group" "nginx_access" {
  name              = "/cop/${var.environment}/nginx/access"
  retention_in_days = 30

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "nginx_error" {
  name              = "/cop/${var.environment}/nginx/error"
  retention_in_days = 30

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "ec2_system" {
  name              = "/cop/${var.environment}/ec2/system"
  retention_in_days = 30

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "platform_health" {
  dashboard_name = "${var.environment}-cop-platform-health"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ALB Request Count"
          view   = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ALB 5XX Errors"
          view   = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB Unhealthy Host Count"
          view   = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/ApplicationELB", "UnHealthyHostCount", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix]
          ]
          period = 300
          stat   = "Maximum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "EC2 CPU Utilisation"
          view   = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
  type   = "metric"
  x      = 0
  y      = 12
  width  = 12
  height = 6
  properties = {
    title  = "EC2 Memory Utilisation"
    view   = "timeSeries"
    region = var.aws_region
    metrics = [
      [{ "expression" = "SEARCH('{COP/EC2} MetricName=\"mem_used_percent\"', 'Average', 60)", "label" = "Memory Used %", "id" = "e1" }]
    ]
    period = 60
  }
},
      {
  type   = "metric"
  x      = 12
  y      = 12
  width  = 12
  height = 6
  properties = {
    title  = "EC2 Disk Utilisation"
    view   = "timeSeries"
    region = var.aws_region
    metrics = [
      [{ "expression" = "SEARCH('{COP/EC2,device,fstype,host,path} MetricName=\"disk_used_percent\" path=\"/\"', 'Average', 60)", "label" = "Disk Used %", "id" = "e2" }]
    ]
    period = 60
  }
},
      {
        type   = "alarm"
        x      = 0
        y      = 18
        width  = 24
        height = 4
        properties = {
          title  = "Platform Alarms"
          alarms = [
            aws_cloudwatch_metric_alarm.alb_5xx_errors.arn,
            aws_cloudwatch_metric_alarm.unhealthy_host_count.arn,
            aws_cloudwatch_metric_alarm.ec2_cpu_high.arn
          ]
        }
      }
    ]
  })
}