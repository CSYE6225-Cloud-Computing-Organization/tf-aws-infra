variable "aws_profile" {
  description = "The AWS profile to use"
  type        = string

}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "The availability zones to deploy the subnets"
  type        = list(string)
}

variable "AWS_REGION" {
  description = "The AWS region to deploy resources in"
  type        = string

}
variable "ami" {
  description = "AMI ID to use for the EC2 instance"
}

variable "instance_type" {
  description = "EC2 instance type"
}

variable "application_port" {
  description = "The port number used by the application"
  type        = number
}

variable "common_cidr_block" {
  description = "Common CIDR block for accessible IPs"
  type        = string
  default     = "0.0.0.0/0"
}