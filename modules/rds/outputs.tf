output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.default.endpoint
}

output "db_security_group_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.db_security_group.id
}

output "db_instance_id" {
  value       = aws_db_instance.default.id
  description = "The database endpoint"
}

