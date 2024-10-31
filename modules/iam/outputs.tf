output "iam_role_arn" {
  value       = aws_iam_role.ec2_role.arn
  description = "The ARN of the IAM role created for EC2 instances"
}

output "iam_instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_profile.name
  description = "ARN of the IAM instance profile for EC2 instances"
}