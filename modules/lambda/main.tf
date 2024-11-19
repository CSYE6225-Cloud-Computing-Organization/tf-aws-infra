# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role_${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda to Access Logs and SNS
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
          "sns:Publish" # Permissions needed to publish messages to SNS
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "verify_email" {
  function_name = "verifyemail-${var.environment}"
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  filename = var.lambda_filename

  role = aws_iam_role.lambda_exec_role.arn

  # Memory and Timeout Settings
  memory_size = 512 # Allocate 512 MB memory
  timeout     = 20  # Set timeout to 15 seconds

  # Environment Variables
  environment {
    variables = {
      SENDGRID_API_KEY       = var.sendgrid_api_key
      VERIFICATION_LINK_BASE = var.verification_link_base
      FROM_EMAIL             = var.from_email
    }
  }

  # Ensure IAM role and policies are created first
  depends_on = [aws_iam_role_policy.lambda_exec_policy]
}
