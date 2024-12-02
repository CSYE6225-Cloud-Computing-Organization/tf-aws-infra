variable "secrets_manager_kms_key_id" {
  description = "The ID of the KMS key used to encrypt secrets"
  type        = string
}

variable "rds_endpoint" {
  description = "The RDS instance endpoint"
  type        = string
}

variable "db_username" {
  description = "Username for the database server"
  type        = string
}

variable "db_password" {
  description = "Password for the database server"
  type        = string
}

variable "from_email" {
  description = "The from email address used in the lambda function"
  type        = string
}

variable "sendgrid_api_key" {
  description = "SendGrid API key for sending emails"
  type        = string
}

variable "jwt_secret" {
  description = "JWT secret used for encoding/decoding JWT tokens"
  type        = string
}

variable "verification_link_base" {
  description = "Base URL for email verification links"
  type        = string
}

# Database Credentials Variables
variable "db_secret_name" {
  description = "Name of the database credentials secret"
  type        = string
}

variable "lambda_email_secret_name" {
  description = "Name of the Lambda email credentials secret"
  type        = string
}