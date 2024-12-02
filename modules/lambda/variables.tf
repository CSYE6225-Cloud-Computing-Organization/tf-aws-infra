# modules/lambda/variables.tf

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for email verification"
  type        = string
}


variable "sendgrid_api_key" {
  description = "API key for SendGrid"
  type        = string
  sensitive   = true
}


variable "verification_link_base" {
  description = "Base URL for the email verification link"
  type        = string
}

variable "from_email" {
  description = "Sender email address for verification emails"
  type        = string
}

variable "environment" {
  description = "Environment for the Lambda function (e.g., dev, prod)"
  type        = string
}

variable "lambda_filename" {
  description = "Local path to the Lambda zip file"
  type        = string
}

variable "lambda_email_credentials_secret_id" {
  type        = string
  description = "ARN for the Lambda email credentials secret"
}

variable "secrets_manager_kms_key_arn" {
  type        = string
  description = "KMS key ID used for encrypting environment variables"
}


variable "lambda_secret_name" {
  description = "Name of the secret in Secrets Manager"
  type        = string
}

