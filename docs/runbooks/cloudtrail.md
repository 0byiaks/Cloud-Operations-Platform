# CloudTrail Runbook

## Overview
CloudTrail records every AWS API call made in the account — who did what,
when, and from where. Logs are delivered to S3 every 15 minutes.

## Trail Details

| Detail | Value |
|---|---|
| Trail name | cop-cloudtrail |
| Region | eu-west-2 |
| S3 bucket | cop-cloudtrail-logs-716769866080 |
| Log validation | Enabled |
| Global events | Enabled |
| Managed by | Terraform — terraform/account/cloudtrail/ |

## Checking Trail Status

```bash
aws cloudtrail get-trail-status \
  --name cop-cloudtrail \
  --profile cop-terraform \
  --query "{Logging:IsLogging,LatestDelivery:LatestDeliveryTime}" \
  --output table
```

## Querying Logs — Who Did What

```bash
# Look up events for a specific user
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=Username,AttributeValue=cop-terraform-user \
  --profile cop-terraform \
  --query "Events[*].{Time:EventTime,Event:EventName,User:Username}" \
  --output table

# Look up a specific event type
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=RunInstances \
  --profile cop-terraform \
  --query "Events[*].{Time:EventTime,Event:EventName,User:Username}" \
  --output table

# Look up events in a time window
aws cloudtrail lookup-events \
  --start-time 2026-08-31T00:00:00Z \
  --end-time 2026-08-31T23:59:59Z \
  --profile cop-terraform \
  --query "Events[*].{Time:EventTime,Event:EventName,User:Username}" \
  --output table
```

## Validating Log Integrity

```bash
aws cloudtrail validate-logs \
  --trail-arn arn:aws:cloudtrail:eu-west-2:716769866080:trail/cop-cloudtrail \
  --start-time 2026-08-31T00:00:00Z \
  --profile cop-terraform
```

## Common Investigation Scenarios

**Who deleted a resource?**
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=DeleteSecurityGroup \
  --profile cop-terraform
```

**Who changed an IAM policy?**
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=PutUserPolicy \
  --profile cop-terraform
```

**What did a specific IP address do?**
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=<ip-address> \
  --profile cop-terraform
```

## Log Retention
Logs expire after 90 days via S3 lifecycle rule.
Old versions expire after 30 days.