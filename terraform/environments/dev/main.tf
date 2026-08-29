# Data source - Route53 hosted zone
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# VPC
module "vpc" {
  source = "git::https://github.com/0byiaks/terraform-aws-modules.git//modules/vpc?ref=main"

  environment  = var.environment
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr

  public_subnet_az1_cidr       = var.public_subnet_az1_cidr
  public_subnet_az2_cidr       = var.public_subnet_az2_cidr
  private_subnet_app_az1_cidr  = var.private_subnet_app_az1_cidr
  private_subnet_app_az2_cidr  = var.private_subnet_app_az2_cidr
  private_subnet_data_az1_cidr = var.private_subnet_data_az1_cidr
  private_subnet_data_az2_cidr = var.private_subnet_data_az2_cidr
}

# IAM
module "iam" {
  source = "../../modules/iam"

  environment    = var.environment
  project_name   = var.project_name
  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id
}

# ACM
module "acm" {
  source = "git::https://github.com/0byiaks/terraform-aws-modules.git//modules/acm?ref=main"

  environment  = var.environment
  project_name = var.project_name
  domain_name  = var.domain_name
}

# ALB
module "alb" {
  source = "git::https://github.com/0byiaks/terraform-aws-modules.git//modules/alb?ref=main"

  environment  = var.environment
  project_name = var.project_name

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.vpc.alb_security_group_id
  certificate_arn       = module.acm.acm_certificate_arn
  load_balancer_type    = var.load_balancer_type
  target_type           = var.target_type
  health_check_path     = var.health_check_path
}

# Route53
module "route53" {
  source = "git::https://github.com/0byiaks/terraform-aws-modules.git//modules/route53?ref=main"

  environment    = var.environment
  project_name   = var.project_name
  zone_id        = data.aws_route53_zone.main.zone_id
  record_name    = var.domain_name
  alb_dns_name   = module.alb.alb_dns_name
  alb_zone_id    = module.alb.alb_zone_id
  operator_email = var.operator_email
}

# ASG
module "asg" {
  source = "../../modules/asg"

  environment  = var.environment
  project_name = var.project_name

  instance_type                = var.instance_type
  min_size                     = var.asg_min_size
  max_size                     = var.asg_max_size
  desired_capacity             = var.asg_desired

  private_subnet_app_ids       = module.vpc.private_app_subnet_ids
  app_server_security_group_id = module.vpc.app_server_security_group_id
  ec2_instance_profile_name    = module.iam.ec2_instance_profile_name
  alb_target_group_arn         = module.alb.alb_target_group_arn
  sns_topic_arn                = module.route53.sns_topic_arn
}