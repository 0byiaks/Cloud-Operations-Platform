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

# -----------------------------------------------------------------------------
# Legacy EC2 stack (decommissioned). Uncomment to restore ASG/ALB/EC2.
# -----------------------------------------------------------------------------
# IAM
# module "iam" {
#   source = "../../modules/iam"
#
#   environment    = var.environment
#   project_name   = var.project_name
#   aws_region     = var.aws_region
#   aws_account_id = var.aws_account_id
# }

# ACM
module "acm" {
  source = "git::https://github.com/0byiaks/terraform-aws-modules.git//modules/acm?ref=main"

  environment  = var.environment
  project_name = var.project_name
  domain_name  = var.domain_name
}

# ALB
# module "alb" {
#   source = "git::https://github.com/0byiaks/terraform-aws-modules.git//modules/alb?ref=main"
#
#   environment  = var.environment
#   project_name = var.project_name
#
#   vpc_id                = module.vpc.vpc_id
#   public_subnet_ids     = module.vpc.public_subnet_ids
#   alb_security_group_id = module.vpc.alb_security_group_id
#   certificate_arn       = module.acm.acm_certificate_arn
#   load_balancer_type    = var.load_balancer_type
#   target_type           = var.target_type
#   health_check_path     = var.health_check_path
# }
#
# Route53 (apex record + SNS for the EC2 ALB)
# module "route53" {
#   source = "git::https://github.com/0byiaks/terraform-aws-modules.git//modules/route53?ref=main"
#
#   environment    = var.environment
#   project_name   = var.project_name
#   zone_id        = data.aws_route53_zone.main.zone_id
#   record_name    = var.domain_name
#   alb_dns_name   = module.alb.alb_dns_name
#   alb_zone_id    = module.alb.alb_zone_id
#   operator_email = var.operator_email
# }
#
# ASG
# module "asg" {
#   source = "../../modules/asg"
#
#   environment  = var.environment
#   project_name = var.project_name
#
#   instance_type    = var.instance_type
#   min_size         = var.asg_min_size
#   max_size         = var.asg_max_size
#   desired_capacity = var.asg_desired
#
#   private_subnet_app_ids       = module.vpc.private_app_subnet_ids
#   app_server_security_group_id = module.vpc.app_server_security_group_id
#   ec2_instance_profile_name    = module.iam.ec2_instance_profile_name
#   alb_target_group_arn         = module.alb.alb_target_group_arn
#   sns_topic_arn                = module.route53.sns_topic_arn
# }
#
# Monitoring (EC2/ALB alarms)
# module "monitoring" {
#   source = "../../modules/monitoring"
#
#   environment             = var.environment
#   project_name            = var.project_name
#   aws_region              = var.aws_region
#   sns_topic_arn           = module.route53.sns_topic_arn
#   alb_arn_suffix          = local.alb_arn_suffix
#   target_group_arn_suffix = local.target_group_arn_suffix
#   asg_name                = module.asg.asg_name
#   vpc_id                  = module.vpc.vpc_id
# }
# -----------------------------------------------------------------------------

# EKS
module "eks" {
  source = "../../modules/eks"

  project_name    = var.project_name
  aws_account_id  = var.aws_account_id
  environment     = var.environment
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_app_subnet_ids

  app_node_instance_type      = var.app_node_instance_type
  platform_node_instance_type = var.platform_node_instance_type
  app_node_min                = var.app_node_min
  app_node_max                = var.app_node_max
  app_node_desired            = var.app_node_desired
  platform_node_min           = var.platform_node_min
  platform_node_max           = var.platform_node_max
  platform_node_desired       = var.platform_node_desired
}

# EKS-Platform
module "eks-platform" {
  source = "../../modules/eks-platform"

  cluster_name                  = module.eks.cluster_name
  cluster_endpoint              = module.eks.cluster_endpoint
  cluster_certificate_authority = module.eks.cluster_certificate_authority
  oidc_provider_arn             = module.eks.oidc_provider_arn
  cluster_oidc_issuer           = module.eks.cluster_oidc_issuer
  oidc_issuer                   = module.eks.oidc_issuer
  environment                   = var.environment
  project_name                  = var.project_name
  aws_region                    = var.aws_region
  aws_account_id                = var.aws_account_id
  vpc_id                        = module.vpc.vpc_id

  access_entry_arns = [
    module.eks.cluster_access_entry_arn,
    module.eks.github_actions_access_entry_arn
  ]

}

# Apex DNS for the NovaCorp Ingress ALB (titotest.co.uk).
# The ALB is created by the AWS Load Balancer Controller after ArgoCD
# syncs the Ingress — not by this stack — so plan must succeed when
# zero ALBs match. Route53 is created on a later apply once exactly
# one Ingress ALB exists.
data "aws_lbs" "novacorp_ingress" {
  tags = {
    "elbv2.k8s.aws/cluster" = var.cluster_name
    "ingress.k8s.aws/stack" = "novacorp/novacorp-ingress"
  }

  depends_on = [module.eks-platform]
}

data "aws_lb" "novacorp_ingress" {
  count = length(data.aws_lbs.novacorp_ingress.arns) == 1 ? 1 : 0
  arn   = one(data.aws_lbs.novacorp_ingress.arns)
}

resource "aws_route53_record" "apex" {
  count   = length(data.aws_lb.novacorp_ingress) == 1 ? 1 : 0
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = data.aws_lb.novacorp_ingress[0].dns_name
    zone_id                = data.aws_lb.novacorp_ingress[0].zone_id
    evaluate_target_health = false
  }
}

moved {
  from = aws_route53_record.apex
  to   = aws_route53_record.apex[0]
}

# import {
#   to = module.monitoring.aws_cloudwatch_log_group.vpc_flow_logs
#   id = "/cop/dev/vpc-flow-logs"
# }

import {
  to = module.eks.aws_eks_access_entry.github_actions
  id = "cop-eks-cluster:arn:aws:iam::716769866080:role/cop-github-actions-role"
}

module "ecr" {
  source           = "../../modules/ecr"
  repository_names = var.ecr_repository_names
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
