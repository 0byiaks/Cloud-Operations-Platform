# Cloud Operations Platform — Platform Overview

## What is COP
The Cloud Operations Platform (COP) is a persistent AWS-hosted platform 
operated as a simulated real-world DevOps environment. It starts as a 
static web hosting platform and evolves over time to include containers, 
CI/CD, Kubernetes, and microservices.

## Architecture



## Infrastructure Summary

| Component | Resource | Details |
|---|---|---|
| DNS | Route53 | titotest.co.uk hosted zone |
| Certificate | ACM | titotest.co.uk + wildcard |
| Load Balancer | ALB | dev-cop-alb, eu-west-2 |
| Compute | ASG | dev-cop-asg, min 1, max 2, t3.micro |
| Networking | VPC | 10.0.0.0/16, 2 AZs, public + private subnets |
| State | S3 | cop-terraform-state-716769866080 |
| Monitoring | CloudWatch | 3 alarms — ALB 5XX, unhealthy hosts, EC2 CPU |
| Notifications | SNS | dev-cop-sns-topic, email subscription |

## Repo Structure


## Branch Strategy

- main — stable, represents deployed state
- develop — integration branch
- feature/* — one branch per ticket

## AWS Account
- Account ID: 716769866080
- Region: eu-west-2 (London)
- Terraform user: cop-terraform-user
- CLI profile: cop-terraform

## Daily Operational Checks
1. Check CloudWatch alarms — all should be in OK state
2. Check ASG instance count — should match desired capacity
3. Check ALB target group — all targets healthy
4. Check AWS Cost Explorer — no unexpected spend

## Useful Commands

```bash
# Check alarm states
aws cloudwatch describe-alarms \
  --query "MetricAlarms[*].{Name:AlarmName,State:StateValue}" \
  --output table --profile cop-terraform

# Check ASG instances
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names dev-cop-asg \
  --query "AutoScalingGroups[0].Instances[*].{ID:InstanceId,State:LifecycleState,Health:HealthStatus}" \
  --output table --profile cop-terraform

# Check ALB target health
aws elbv2 describe-target-health \
  --target-group-arn $(aws elbv2 describe-target-groups \
  --query "TargetGroups[?contains(TargetGroupName, 'cop')].TargetGroupArn" \
  --output text --profile cop-terraform) \
  --query "TargetHealthDescriptions[*].{ID:Target.Id,State:TargetHealth.State}" \
  --output table --profile cop-terraform

# Get Terraform outputs
cd terraform/environments/dev
terraform output
```