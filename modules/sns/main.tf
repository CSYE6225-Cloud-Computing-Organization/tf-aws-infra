# modules/sns/main.tf

# Define the SNS Topic
resource "aws_sns_topic" "send_verification_email" {
  name = "sendVerificationEmail"
}

# Attach a policy to allow Lambda to publish to the SNS Topic
resource "aws_sns_topic_policy" "send_verification_email_policy" {
  arn    = aws_sns_topic.send_verification_email.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

# Policy document for SNS Topic
data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    actions   = ["SNS:Publish"]
    effect    = "Allow"
    resources = [aws_sns_topic.send_verification_email.arn]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# SNS subscription to link SNS topic to the Lambda function
resource "aws_sns_topic_subscription" "verify_email_subscription" {
  topic_arn = aws_sns_topic.send_verification_email.arn
  protocol  = "lambda"
  endpoint  = var.lambda_function_arn
}

# Grant SNS permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_sns_invoke_lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.send_verification_email.arn
}
