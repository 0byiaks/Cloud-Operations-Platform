# ASG Scaling Runbook

## Overview
The COP Auto Scaling Group scales EC2 instances based on CPU utilisation
using a target tracking scaling policy. Target CPU is 60% — ASG scales
out when above, scales in when below.

## Scaling Policy Details

| Detail | Value |
|---|---|
| ASG name | dev-cop-asg |
| Policy type | Target Tracking |
| Metric | ASGAverageCPUUtilization |
| Target value | 60% |
| Min instances | 1 |
| Max instances | 2 |
| Health check type | ELB |
| Health check grace period | 300 seconds |

## Checking ASG State

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names dev-cop-asg \
  --profile cop-terraform \
  --query "AutoScalingGroups[0].{Min:MinSize,Max:MaxSize,Desired:DesiredCapacity,Instances:Instances[*].{ID:InstanceId,State:LifecycleState,Health:HealthStatus}}" \
  --output json
```

## Checking Scaling Activity

```bash
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name dev-cop-asg \
  --profile cop-terraform \
  --query "Activities[*].{Time:StartTime,Description:Description,Status:StatusCode}" \
  --output table
```

## How Target Tracking Works
AWS automatically creates two CloudWatch alarms:
- **AlarmHigh** — fires when CPU > 60%, triggers scale-out
- **AlarmLow** — fires when CPU < 42%, triggers scale-in

You do not manage these alarms directly — they are owned by the scaling policy.

## Simulating a Traffic Spike

```bash
# Run load simulation — duration in minutes, concurrency
./scripts/traffic/simulate_load.sh 10 50

# For higher load to trigger scale-out
./scripts/traffic/simulate_load.sh 10 200
```

## Simulating CPU Spike via Stress Tool

```bash
# Get instance ID
INSTANCE_ID=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names dev-cop-asg \
  --profile cop-terraform \
  --query "AutoScalingGroups[0].Instances[0].InstanceId" \
  --output text)

# Connect via SSM
aws ssm start-session --target $INSTANCE_ID --profile cop-terraform

# Inside instance — stress CPU for 5 minutes
sudo dnf install -y stress
stress --cpu 4 --timeout 300
```

## Expected Scaling Behaviour
1. CPU climbs above 60% and stays there
2. AlarmHigh fires after 3 consecutive datapoints
3. ASG launches a second instance — state goes Pending → InService
4. ALB registers new instance after health check passes
5. Load distributes across both instances
6. CPU drops as load is shared
7. AlarmLow fires when CPU stays below 42% for 15 datapoints
8. ASG terminates the extra instance
9. Platform returns to single instance

## Manual Scale-Out
If you need to manually add an instance:
```bash
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name dev-cop-asg \
  --desired-capacity 2 \
  --profile cop-terraform
```

## Manual Scale-In
```bash
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name dev-cop-asg \
  --desired-capacity 1 \
  --profile cop-terraform
```