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
  description = "List of subnet IDs for the Application Load Balancer and Auto Scaling Group"
  type        = list(string)
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

variable "iam_instance_profile" {
  description = "IAM instance profile for the EC2 instance"
  type        = string
}

variable "route53_zone_id" {
  description = "ID of the Route 53 zone."
  type        = string
}

variable "domain_name" {
  description = "Domain name associated with the EC2 instance."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., staging, production)."
  type        = string
}

variable "AWS_REGION" {
  description = "The AWS region to deploy resources in"
  type        = string

}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket created in the S3 module"
  type        = string
}

variable "key_name" {
  description = "The key pair name for the EC2 instances"
  type        = string
}

# Auto Scaling Group capacity settings
variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

# CPU utilization thresholds for scaling
variable "scale_up_threshold" {
  description = "CPU utilization threshold to trigger scale-up"
  type        = number
  default     = 9
}

variable "scale_down_threshold" {
  description = "CPU utilization threshold to trigger scale-down"
  type        = number
  default     = 7.5
}

variable "JWT_SECRET" {
  type        = string
  description = "Secret key for JWT authentication"
}

