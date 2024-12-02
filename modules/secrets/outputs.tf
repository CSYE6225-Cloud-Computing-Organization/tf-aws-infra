output "db_credentials_secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}

output "lambda_email_credentials_secret_arn" {
  value = aws_secretsmanager_secret.lambda_email_credentials.arn
}

output "lambda_email_credentials_secret_name" {
  value = aws_secretsmanager_secret.lambda_email_credentials.name
}
output "lambda_email_credentials_secret_id" {
  value = aws_secretsmanager_secret.lambda_email_credentials.id
}