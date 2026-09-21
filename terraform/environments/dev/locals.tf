locals {
  name_prefix = "${var.environment}-${var.project_name}"

  # Legacy EC2 ALB suffixes — uncomment with the EC2 stack in main.tf
  # alb_arn_suffix          = replace(module.alb.alb_arn, "arn:aws:elasticloadbalancing:${var.aws_region}:${var.aws_account_id}:loadbalancer/", "")
  # target_group_arn_suffix = replace(module.alb.alb_target_group_arn, "arn:aws:elasticloadbalancing:${var.aws_region}:${var.aws_account_id}:targetgroup/", "")
}
