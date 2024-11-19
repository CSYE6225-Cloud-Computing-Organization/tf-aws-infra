# modules/sns/variables.tf

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to subscribe to the SNS topic"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to allow SNS to invoke"
  type        = string
}
