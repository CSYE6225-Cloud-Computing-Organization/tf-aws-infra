output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.subnets.private_subnet_ids
}

output "s3_bucket_name" {
  value       = module.s3.bucket_name
  description = "The name of the created S3 bucket"
}

output "s3_bucket_arn" {
  value       = module.s3.bucket_arn
  description = "The ARN of the created S3 bucket"
}