output "lambda_function_arn" {
  value = aws_lambda_function.verify_email.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.verify_email.function_name
}