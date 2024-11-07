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
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
}

module "rds" {
  source                = "./modules/rds"
  instance_class        = var.instance_class
  db_engine             = var.db_engine
  engine_version        = var.engine_version
  db_identifier         = var.db_identifier
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  subnet_ids            = module.subnets.private_subnet_ids
  app_security_group_id = module.ec2.app_security_group_id
  vpc_id                = module.vpc.vpc_id
}

module "iam" {
  source        = "./modules/iam"
  s3_bucket_arn = module.s3.bucket_arn
}

module "s3" {
  source = "./modules/s3"
}


module "ec2" {
  source               = "./modules/ec2"
  vpc_id               = module.vpc.vpc_id
  ami                  = var.ami
  instance_type        = var.instance_type
  subnet_id            = slice(module.subnets.public_subnet_ids, 0, 3)
  iam_instance_profile = module.iam.iam_instance_profile_name
  route53_zone_id      = var.route53_zone_id
  domain_name          = var.domain_name
  environment          = var.environment
  AWS_REGION           = var.AWS_REGION
  s3_bucket_name       = module.s3.bucket_name
  application_port     = var.application_port
  root_volume_size     = var.root_volume_size
  root_volume_type     = var.root_volume_type
  db_host              = module.rds.db_instance_endpoint
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_identifier        = var.db_identifier
  key_name             = var.key_name
  asg_desired_capacity = var.asg_desired_capacity
  asg_max_size         = var.asg_max_size
  asg_min_size         = var.asg_min_size
  scale_up_threshold   = var.scale_up_threshold
  scale_down_threshold = var.scale_down_threshold

}

# Route 53 Module
module "route53" {
  source          = "./modules/route53"
  domain_name     = var.domain_name
  route53_zone_id = var.route53_zone_id
  environment     = var.environment
  alb_dns_name    = module.ec2.alb_dns_name
  alb_zone_id     = module.ec2.alb_zone_id
}




