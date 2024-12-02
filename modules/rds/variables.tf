variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed"
  type        = string
}

variable "db_engine" {
  description = "Database engine (e.g., 'mysql', 'postgres')"
  type        = string
}

variable "engine_version" {
  description = "Version of the database engine"
  type        = string
}

variable "instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
}

variable "db_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
}

variable "db_name" {
  description = "Name of the database created in the RDS instance"
  type        = string
}

variable "db_username" {
  description = "Username for the database administrator"
  type        = string
}

variable "db_password" {
  description = "Password for the database administrator"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB Subnet Group"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "ID of the application's security group to allow MySQL traffic"
  type        = string
}

variable "rds_key_id" {
  description = "KMS key arn rds"
  type        = string
}