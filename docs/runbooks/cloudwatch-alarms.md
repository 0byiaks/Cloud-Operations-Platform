# CloudWatch Alarms Runbook

## Overview
The COP platform has three CloudWatch alarms monitoring core platform health.
All alarms notify via SNS topic `dev-cop-sns-topic` — email notifications
sent to the operator email on file.

## Alarms

| Alarm | Metric | Threshold | Action |
|---|---|---|---|
| dev-cop-alb-5xx-errors | HTTPCode_ELB_5XX_Count | > 10 over 5 mins | Investigate application errors |
| dev-cop-unhealthy-hosts | UnHealthyHostCount | > 0 over 5 mins | Investigate EC2 instance health |
| dev-cop-ec2-cpu-high | CPUUtilization | > 80% over 10 mins | Investigate load, consider scaling |

## Checking Alarm State

```bash
aws cloudwatch describe-alarms \
  --alarm-names "dev-cop-alb-5xx-errors" "dev-cop-unhealthy-hosts" "dev-cop-ec2-cpu-high" \
  --query "MetricAlarms[*].{Name:AlarmName,State:StateValue,Reason:StateReason}" \
  --output table --profile cop-terraform
```

## Response Procedures

### ALB 5XX Errors Alarm
**What it means:** The application is returning server errors.

1. Check Nginx error logs on the EC2 instance via SSM
```bash
aws ssm start-session --target <instance-id> --profile cop-terraform
sudo tail -100 /var/log/nginx/error.log
```
2. Check ALB access logs if enabled
3. Check if a recent deployment caused the errors
4. If instance is unresponsive — terminate it, ASG will replace it automatically

---

### Unhealthy Hosts Alarm
**What it means:** One or more EC2 instances are failing ALB health checks.

1. Check which instance is unhealthy
```bash
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn> \
  --profile cop-terraform
```
2. Connect to the unhealthy instance via SSM
```bash
aws ssm start-session --target <instance-id> --profile cop-terraform
```
3. Check Nginx is running
```bash
sudo systemctl status nginx
sudo systemctl restart nginx
```
4. If instance cannot be recovered — terminate it
```bash
aws ec2 terminate-instances --instance-ids <instance-id> --profile cop-terraform
```
5. ASG will automatically launch a replacement

---

### EC2 CPU High Alarm
**What it means:** Instance is under heavy load.

1. Check which process is consuming CPU via SSM
```bash
aws ssm start-session --target <instance-id> --profile cop-terraform
top
```
2. If load is legitimate traffic — ASG scaling policy will handle it
3. If load is a runaway process — kill the process or terminate the instance
4. If persistent — review instance sizing, consider upgrading to t3.small

## Adding New Alarms
New alarms are added via Terraform in `terraform/modules/monitoring/main.tf`.
Follow the existing alarm pattern — never create alarms manually in the console.