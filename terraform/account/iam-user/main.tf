# IAM user for Terraform operations
resource "aws_iam_user" "terraform_user" {
  name = var.iam_user_name

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
    Purpose   = "Terraform operations for COP platform"
  }
}

# Access key for programmatic access
resource "aws_iam_access_key" "terraform_user_key" {
  user = aws_iam_user.terraform_user.name
}

# Custom least-privilege policy
resource "aws_iam_policy" "cop_terraform_policy" {
  name        = "cop-terraform-least-privilege"
  description = "Least privilege policy for COP Terraform operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2Permissions"
        Effect = "Allow"
        Action = [
          "ec2:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "ELBPermissions"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "AutoScalingPermissions"
        Effect = "Allow"
        Action = [
          "autoscaling:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "ACMPermissions"
        Effect = "Allow"
        Action = [
          "acm:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "Route53Permissions"
        Effect = "Allow"
        Action = [
          "route53:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudTrailPermissions"
        Effect = "Allow"
        Action = [
          "cloudtrail:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMPermissions"
        Effect = "Allow"
        Action = [
          "iam:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3Permissions"
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchPermissions"
        Effect = "Allow"
        Action = [
          "cloudwatch:*",
          "logs:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "SNSPermissions"
        Effect = "Allow"
        Action = [
          "sns:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "SSMPermissions"
        Effect = "Allow"
        Action = [
          "ssm:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "SecretsManagerPermissions"
        Effect = "Allow"
        Action = [
          "secretsmanager:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "EventBridgePermissions"
        Effect = "Allow"
        Action = [
          "events:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "terraform_user_policy" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = aws_iam_policy.cop_terraform_policy.arn
}

# Store credentials in Secrets Manager
resource "aws_secretsmanager_secret" "terraform_user_credentials" {
  name        = "cop/terraform-user/credentials"
  description = "Access credentials for COP Terraform IAM user"

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "terraform_user_credentials_version" {
  secret_id = aws_secretsmanager_secret.terraform_user_credentials.id

  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.terraform_user_key.id
    secret_access_key = aws_iam_access_key.terraform_user_key.secret
    user_name         = aws_iam_user.terraform_user.name
  })
}