# VPC Flow Logs Runbook

## Overview
VPC Flow Logs capture all network traffic in and out of the COP VPC.
Every accepted and rejected connection is recorded — source IP, destination
IP, port, protocol, and bytes transferred. Essential for security
investigations and network troubleshooting.

## Flow Log Details

| Detail | Value |
|---|---|
| VPC ID | vpc-076fcf28d596462d7 |
| Flow Log ID | fl-0d5097aaff1457c0f |
| Status | ACTIVE |
| Log destination | /cop/dev/vpc-flow-logs |
| Traffic type | ALL (accepted and rejected) |
| Retention | 30 days |
| Managed by | Terraform — terraform/modules/monitoring/ |

## Checking Flow Log Status

```bash
aws ec2 describe-flow-logs \
  --filter "Name=resource-id,Values=vpc-076fcf28d596462d7" \
  --profile cop-terraform \
  --query "FlowLogs[*].{ID:FlowLogId,Status:FlowLogStatus,Destination:LogDestination}" \
  --output table
```

## Viewing Log Streams

```bash
aws logs describe-log-streams \
  --log-group-name "/cop/dev/vpc-flow-logs" \
  --profile cop-terraform \
  --query "logStreams[*].{Stream:logStreamName,LastEvent:lastEventTime}" \
  --output table
```

## Reading Flow Log Entries

```bash
aws logs get-log-events \
  --log-group-name "/cop/dev/vpc-flow-logs" \
  --log-stream-name "<eni-stream-name>" \
  --profile cop-terraform \
  --query "events[*].message" \
  --output text
```

## Understanding Flow Log Format

Each log entry follows this format:
2 716769866080 eni-010431b727186eef1 86.123.45.67 10.0.11.45 443 80 6 10 1234 1234567890 1234567899 ACCEPT OK

