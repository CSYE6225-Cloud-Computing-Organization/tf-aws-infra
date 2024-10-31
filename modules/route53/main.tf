resource "aws_route53_record" "app_record" {
  zone_id = var.route53_zone_id
  name    = "${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 60
  records = [var.ec2_public_ip]
}