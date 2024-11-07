variable "domain_name" {
  description = "The domain name to be used for creating DNS records"
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

variable "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  type        = string
}

variable "alb_zone_id" {
  description = "The hosted zone ID of the Application Load Balancer"
  type        = string
}
