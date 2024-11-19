# Security Group for Load Balancer
resource "aws_security_group" "load_balancer_security_group" {
  vpc_id      = var.vpc_id
  name        = "load balancer security group"
  description = "Security group for Load Balancer to access web application"

  ingress {
    description = "Allow HTTP from anywhere (IPv4)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTP from anywhere (IPv6)"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Allow HTTPS from anywhere (IPv4)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTPS from anywhere (IPv6)"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "load balancer security group"
  }
}


# Application Security Group
resource "aws_security_group" "application_security_group" {
  vpc_id = var.vpc_id
  name   = "application security group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "application security group"
  }
}

# Security Group Rules for Application
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.common_cidr_block]
  security_group_id = aws_security_group.application_security_group.id
}

resource "aws_security_group_rule" "allow_http_from_lb" {
  type                     = "ingress"
  from_port                = var.application_port
  to_port                  = var.application_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.load_balancer_security_group.id
  security_group_id        = aws_security_group.application_security_group.id
}

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "web_app_launch_template" {
  name_prefix   = "csye6225_asg"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  monitoring {
    enabled = true
  }

  network_interfaces {
    security_groups             = [aws_security_group.application_security_group.id]
    associate_public_ip_address = true
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  user_data = base64encode(<<EOF
#!/bin/bash

# Create the .env file with environment variables
cat <<EOT > /home/ubuntu/webapp/.env
PORT='${var.application_port}'
DATABASE_NAME='${var.db_name}'
DATABASE_USER='${var.db_username}'
DATABASE_PASSWORD='${var.db_password}'
DATABASE_HOST='${element(split(":", var.db_host), 0)}'
DATABASE_DIALECT='mysql'
NODE_ENV='production'
S3_BUCKET_NAME='${var.s3_bucket_name}'
AWS_REGION='${var.AWS_REGION}'
STATSD_PORT='8125'

EOT

# Check if webapp.service exists and restart the service
if systemctl list-units --full -all | grep -Fq 'webapp.service'; then
  sudo systemctl enable webapp.service
  sudo systemctl daemon-reload
  sudo systemctl restart webapp.service
fi

sudo chmod 664 /home/ubuntu/webapp/src/logs/app.log
sudo chown csye6225:csye6225 /home/ubuntu/webapp/src/logs/app.log

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/cloudwatch-config.json \
  -s
EOF
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_app_asg" {
  name                = "Webapp-asg"
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  vpc_zone_identifier = var.subnet_id

  launch_template {
    id      = aws_launch_template.web_app_launch_template.id
    version = "$Latest"
  }

  metrics_granularity = "1Minute"

  tag {
    key                 = "Name"
    value               = "webapp"
    propagate_at_launch = true
  }
}


# Scale-up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "cpu-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
}

# Scale-up Alarm
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "cpu-scale-up-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120 # 2-minute period
  statistic           = "Average"
  threshold           = var.scale_up_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }

  alarm_description = "This metric monitors EC2 CPU utilization for scale-out"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

# Scale-down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "cpu-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
}

# Scale-down Alarm
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "cpu-scale-down-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120 # 2-minute period
  statistic           = "Average"
  threshold           = var.scale_down_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }

  alarm_description = "This metric monitors EC2 CPU utilization for scale-in"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}


# Application Load Balancer
resource "aws_lb" "web_app_lb" {
  name               = "webapp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_security_group.id]
  subnets            = var.subnet_id

  enable_deletion_protection = false
}

# Target Group for Load Balancer with Updated Health Check Path
resource "aws_lb_target_group" "web_app_target_group" {
  name     = "webapp-tg"
  port     = var.application_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Listener for Load Balancer
resource "aws_lb_listener" "web_app_lb_listener" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_target_group.arn
  }
}

# Attach Target Group to Auto Scaling Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
  lb_target_group_arn    = aws_lb_target_group.web_app_target_group.arn
}
