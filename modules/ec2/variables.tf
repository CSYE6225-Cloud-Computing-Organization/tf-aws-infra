# Declare vpc_id variable
variable "vpc_id" {
  description = "The VPC ID where the security group and EC2 instance will be created"
  type        = string
}

# Declare application_port variable
variable "application_port" {
  description = "The port number used by the application"
  type        = number
}

# Declare ami variable
variable "ami" {
  description = "The Amazon Machine Image (AMI) ID to use for the EC2 instance"
  type        = string
}

# Declare instance_type variable
variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
}

# Declare subnet_id variable
variable "subnet_id" {
  description = "The subnet ID where the EC2 instance will be deployed"
  type        = string
}

# Declare root_volume_size variable
variable "root_volume_size" {
  description = "The size of the root block device in GiB"
  type        = number
}

# Declare root_volume_type variable
variable "root_volume_type" {
  description = "The type of the root block device (e.g., standard, gp2, io1)"
  type        = string
}

variable "common_cidr_block" {
  description = "Common CIDR block for accessible IPs"
  type        = string
  default     = "0.0.0.0/0"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_username" {
  type        = string
  description = "Database user name"
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "db_identifier" {
  description = "The identifier for the RDS database instance"
  type        = string
}

variable "db_host" {
  description = "The RDS database endpoint"
  type        = string
}


