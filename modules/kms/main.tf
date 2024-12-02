resource "aws_kms_key" "ec2_key" {
  description             = "KMS key for EC2 encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_key" "secrets_manager_key" {
  description             = "KMS key for Secrets Manager to encrypt secrets"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}
