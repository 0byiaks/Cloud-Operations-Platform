# OIDC Identity Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# IAM role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "cop-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # GitHub now issues OIDC subjects with immutable org/repo IDs
            # embedded, e.g. repo:org@ORG_ID/repo@REPO_ID:pull_request
            # (see: gh api repos/${var.github_org}/${var.github_repo}/actions/oidc/customization/sub)
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}@${var.github_org_id}/${var.github_repo}@${var.github_repo_id}:*"
          }
        }
      }
    ]
  })

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# Attach least privilege policy to GitHub Actions role
resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::${var.aws_account_id}:policy/cop-terraform-least-privilege"
}