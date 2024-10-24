output "instance_id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.web_app_instance.id
}

output "public_ip" {
  description = "The public IP of the EC2 instance."
  value       = aws_instance.web_app_instance.public_ip
}

output "app_security_group_id" {
  description = "The security group ID for the EC2 application"
  value       = aws_security_group.application_security_group.id
}
