variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket"
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN to allow EC2 instances to publish messages"
  type        = string
}

variable "db_credentials_secret_arn" {
  description = "ARN of the secret containing database credentials"
  type        = string
}

variable "lambda_email_credentials_secret_arn" {
  description = "ARN of the secret containing Lambda email credentials"
  type        = string
}

variable "ec2_key_arn" {
  description = "ARN of the KMS key used for EC2 encryption"
  type        = string
}

variable "rds_key_arn" {
  description = "ARN of the KMS key used for Rds encryption"
  type        = string
}

variable "s3_key_arn" {
  description = "ARN of the KMS key used for S3 encryption"
  type        = string
}

variable "secrets_manager_key_arn" {
  description = "ARN of the KMS key used for Secrets Manager encryption"
  type        = string
}

variable "lambda_secret_name" {
  description = "Name of the secret in Secrets Manager"
  type        = string
}
# Database Credentials Variables
variable "db_secret_name" {
  description = "Name of the database credentials secret"
  type        = string
}

variable "AWS_REGION" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "aws_account_id" {
  description = "The AWS Account Id"
  type        = string
}