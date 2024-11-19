output "sns_topic_arn" {
  value = aws_sns_topic.send_verification_email.arn
}
