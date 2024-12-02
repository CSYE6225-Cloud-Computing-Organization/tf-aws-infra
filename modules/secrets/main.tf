# Secrets Manager Secret for DB Credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name       = var.db_secret_name
  kms_key_id = var.secrets_manager_kms_key_id
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    host     = var.rds_endpoint,
    username = var.db_username,
    password = var.db_password
  })
}

# Secrets Manager Secret for Lambda Email Credentials
resource "aws_secretsmanager_secret" "lambda_email_credentials" {
  name       = var.lambda_email_secret_name
  kms_key_id = var.secrets_manager_kms_key_id
}

resource "aws_secretsmanager_secret_version" "lambda_email_credentials" {
  secret_id = aws_secretsmanager_secret.lambda_email_credentials.id
  secret_string = jsonencode({
    FROM_EMAIL             = var.from_email,
    SENDGRID_API_KEY       = var.sendgrid_api_key,
    VERIFICATION_LINK_BASE = var.verification_link_base
  })
}
