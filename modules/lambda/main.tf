# IAM Role for Lambda

# Lambda Role and Attachments
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Lambda to Access Logs, SNS, and Secrets Manager
resource "aws_iam_role_policy" "lambda_exec_policy" {
  role = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "sns:Publish",                   # Permissions needed to publish messages to SNS
          "secretsmanager:GetSecretValue", # Permissions needed to access Secrets Manager
          "secretsmanager:DescribeSecret",
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}


data "aws_secretsmanager_secret_version" "lambda_email_credentials" {
  secret_id     = var.lambda_email_credentials_secret_id
  version_stage = "AWSCURRENT"
}


# Lambda Function with Environment Variables
resource "aws_lambda_function" "verify_email" {
  function_name = "verifyemail-${var.environment}"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = var.lambda_filename
  role          = aws_iam_role.lambda_exec_role.arn
  memory_size   = 512 # Allocate 512 MB memory
  timeout       = 20  # Set timeout to 20 seconds

  # Environment Variables pulled from Secrets Manager
  environment {
    variables = {
      SECRETS_MANAGER_ARN = data.aws_secretsmanager_secret_version.lambda_email_credentials.secret_id
    }
  }

  kms_key_arn = var.secrets_manager_kms_key_arn # KMS key for encrypting environment variables
}
