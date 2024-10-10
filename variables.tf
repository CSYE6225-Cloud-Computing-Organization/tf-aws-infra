variable "aws_profile" {
  description = "The AWS profile to use"
  type        = string
  
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
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
