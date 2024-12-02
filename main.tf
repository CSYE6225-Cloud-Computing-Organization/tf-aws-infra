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
  rds_key_id            = module.kms.rds_key_id
}

module "iam" {
  source                              = "./modules/iam"
  db_credentials_secret_arn           = module.secrets.db_credentials_secret_arn
  lambda_email_credentials_secret_arn = module.secrets.lambda_email_credentials_secret_arn
  ec2_key_arn                         = module.kms.ec2_key_arn
  rds_key_arn                         = module.kms.rds_key_id
  s3_key_arn                          = module.kms.s3_key_arn
  secrets_manager_key_arn             = module.kms.secrets_manager_key_arn
  lambda_secret_name                  = var.lambda_secret_name
  db_secret_name                      = var.db_secret_name
  AWS_REGION                          = var.AWS_REGION
  aws_account_id                      = var.aws_account_id
  s3_bucket_arn                       = module.s3.bucket_arn
  sns_topic_arn                       = module.sns.sns_topic_arn
}

module "s3" {
  source      = "./modules/s3"
  kms_key_arn = module.kms.s3_key_arn
}


module "ec2" {
  source                    = "./modules/ec2"
  vpc_id                    = module.vpc.vpc_id
  ami                       = var.ami
  instance_type             = var.instance_type
  subnet_id                 = slice(module.subnets.public_subnet_ids, 0, 3)
  iam_instance_profile      = module.iam.iam_instance_profile_name
  route53_zone_id           = var.route53_zone_id
  domain_name               = var.domain_name
  environment               = var.environment
  AWS_REGION                = var.AWS_REGION
  ec2_key_arn               = module.kms.ec2_key_arn
  s3_bucket_name            = module.s3.bucket_name
  certificate_arn           = var.certificate_arn
  application_port          = var.application_port
  root_volume_size          = var.root_volume_size
  root_volume_type          = var.root_volume_type
  db_host                   = module.rds.db_instance_endpoint
  db_name                   = var.db_name
  db_username               = var.db_username
  db_password               = var.db_password
  db_identifier             = var.db_identifier
  JWT_SECRET                = var.jwt_secret
  sns_arn                   = module.sns.sns_topic_arn
  key_name                  = var.key_name
  db_credentials_secret_arn = module.secrets.db_credentials_secret_arn
  asg_desired_capacity      = var.asg_desired_capacity
  asg_max_size              = var.asg_max_size
  asg_min_size              = var.asg_min_size
  scale_up_threshold        = var.scale_up_threshold
  scale_down_threshold      = var.scale_down_threshold
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

module "lambda" {
  source                             = "./modules/lambda"
  depends_on                         = [module.iam, module.secrets]
  sns_topic_arn                      = module.sns.sns_topic_arn
  secrets_manager_kms_key_arn        = module.kms.secrets_manager_key_arn
  lambda_email_credentials_secret_id = module.secrets.lambda_email_credentials_secret_id
  lambda_secret_name                 = var.lambda_secret_name
  lambda_filename                    = var.lambda_filename
  sendgrid_api_key                   = var.sendgrid_api_key
  verification_link_base             = var.verification_link_base
  from_email                         = var.from_email
  environment                        = var.environment
}



module "sns" {
  source               = "./modules/sns"
  lambda_function_arn  = module.lambda.lambda_function_arn
  lambda_function_name = module.lambda.lambda_function_name
}


module "kms" {
  source = "./modules/kms"
}

module "secrets" {
  source                     = "./modules/secrets"
  secrets_manager_kms_key_id = module.kms.secrets_manager_key_arn
  rds_endpoint               = module.rds.db_instance_endpoint
  db_secret_name             = var.db_secret_name
  lambda_email_secret_name   = var.lambda_secret_name
  db_username                = var.db_username
  db_password                = var.db_password
  from_email                 = var.from_email
  sendgrid_api_key           = var.sendgrid_api_key
  jwt_secret                 = var.jwt_secret
  verification_link_base     = var.verification_link_base
}