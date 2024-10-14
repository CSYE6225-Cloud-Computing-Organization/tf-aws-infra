provider "aws" {
  profile = var.aws_profile
  region  = var.AWS_REGION
}

# VPC Module - This outputs the VPC ID
module "vpc" {
  source         = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  vpc_name       = var.vpc_name
}

# Subnets Module - This outputs the public and private subnet IDs
module "subnets" {
  source               = "./modules/subnet"
  vpc_id               = module.vpc.vpc_id
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}


# Routing Module - Pass the VPC ID and subnet IDs to the routing module
    module "routing" {
  source             = "./modules/routing"
  vpc_id             = module.vpc.vpc_id                 # Get the VPC ID from the VPC module
  public_subnet_ids  = module.subnets.public_subnet_ids  # Pass public subnet IDs from subnets module
  private_subnet_ids = module.subnets.private_subnet_ids # Pass private subnet IDs from subnets module
}
