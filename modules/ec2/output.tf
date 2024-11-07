# Output for Application Load Balancer DNS Name
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.web_app_lb.dns_name
}

# Output for Application Load Balancer Zone ID
output "alb_zone_id" {
  description = "The hosted zone ID of the Application Load Balancer"
  value       = aws_lb.web_app_lb.zone_id
}

# Output for Application Security Group ID
output "app_security_group_id" {
  description = "The security group ID for the EC2 application"
  value       = aws_security_group.application_security_group.id
}
