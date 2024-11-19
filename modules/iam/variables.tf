variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket"
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN to allow EC2 instances to publish messages"
  type        = string
}