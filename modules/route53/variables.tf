variable "domain_name" {
  description = "The domain name to be used for creating DNS records"
  type        = string
}

variable "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 Hosted Zone"
  type        = string
}

variable "environment" {
  description = "environment (dev/demo)"
  type        = string
}
