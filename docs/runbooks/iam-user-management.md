# IAM User Management Runbook

## Overview
The COP platform uses a dedicated IAM user `cop-terraform-user` for all 
Terraform operations. Root credentials are never used for day-to-day work.

## IAM User Details

| Detail | Value |
|---|---|
| Username | cop-terraform-user |
| AWS CLI profile | cop-terraform |
| Credentials location | AWS Secrets Manager — cop/terraform-user/credentials |
| Policy | cop-terraform-least-privilege |
| Managed by | Terraform — terraform/account/iam-user/ |

## Permissions
The user has service-level permissions for:
- EC2, ELB, Auto Scaling
- ACM, Route53
- IAM, S3
- CloudWatch, SNS, SSM
- Secrets Manager, EventBridge

## Retrieving Credentials

```bash
aws secretsmanager get-secret-value \
  --secret-id cop/terraform-user/credentials \
  --query SecretString \
  --output text
```

## Rotating Credentials
If credentials need to be rotated:

1. Navigate to the IAM user Terraform config
```bash
cd terraform/account/iam-user
```

2. Taint the access key to force recreation
```bash
terraform taint aws_iam_access_key.terraform_user_key
```

3. Apply to generate new credentials
```bash
terraform apply
```

4. Retrieve new credentials from Secrets Manager
```bash
aws secretsmanager get-secret-value \
  --secret-id cop/terraform-user/credentials \
  --query SecretString \
  --output text
```

5. Update AWS CLI profile with new credentials
```bash
aws configure --profile cop-terraform
```

6. Verify new credentials work
```bash
aws sts get-caller-identity --profile cop-terraform
```

## Updating Permissions
If a new AWS service is added to the platform:

1. Add the service permissions to the policy in `terraform/account/iam-user/main.tf`
2. Run `terraform plan` to verify the change
3. Run `terraform apply` to apply
4. Test that Terraform can manage the new service resources

## Break Glass — Root Access
Root credentials should only be used if:
- The cop-terraform-user is locked out
- A critical account-level action is required

Root access keys should remain deleted. Use the AWS console with root 
email/password login for emergency access only.