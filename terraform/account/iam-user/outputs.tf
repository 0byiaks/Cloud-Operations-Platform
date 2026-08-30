output "iam_user_name" {
  description = "Name of the Terraform IAM user"
  value       = aws_iam_user.terraform_user.name
}

output "access_key_id" {
  description = "Access key ID for the Terraform IAM user"
  value       = aws_iam_access_key.terraform_user_key.id
}

output "credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret storing the credentials"
  value       = aws_secretsmanager_secret.terraform_user_credentials.arn
}