# Security Group for Load Balancer
resource "aws_security_group" "load_balancer_security_group" {
  vpc_id      = var.vpc_id
  name        = "load balancer security group"
  description = "Security group for Load Balancer to access web application"

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

  user_data = base64encode(<<-EOF
#!/bin/bash

# Update and install AWS CLI and jq
sudo apt-get update && sudo apt-get install -y curl unzip
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
if ! aws --version; then
  echo "AWS CLI installation failed"
  exit 1
fi

# Function to check AWS credentials
check_aws_credentials() {
  for i in {1..150}; do
    if aws sts get-caller-identity >/dev/null 2>&1; then
      echo "AWS credentials available"
      return 0
    fi
    echo "Waiting for AWS credentials... attempt $i"
    sleep 10
  done
  return 1
}

# Function to fetch secrets
fetch_secrets() {
  for i in {1..60}; do
    echo "Attempting to fetch secrets... attempt $i"
    
    # Fetch database credentials
    DB_SECRETS=$(aws secretsmanager get-secret-value --secret-id "${var.db_credentials_secret_arn}" --region "${var.AWS_REGION}" --query 'SecretString' --output text)
    if [ $? -eq 0 ]; then
      DB_USERNAME=$(echo $DB_SECRETS | jq -r .username)
      DB_PASSWORD=$(echo $DB_SECRETS | jq -r .password)
      DB_HOST_FULL=$(echo $DB_SECRETS | jq -r .host)
      DB_HOST=$(echo $DB_HOST_FULL | cut -d':' -f1)
      
      # Verify we got valid values
      if [ "$DB_HOST" != "null" ] && [ "$DB_HOST" != "" ] && [ "$DB_HOST" != "localhost" ]; then
        echo "Successfully retrieved DB credentials with host: $DB_HOST"
        return 0
      else
        echo "Invalid DB_HOST value: $DB_HOST"
      fi
    fi
    
    sleep 10
  done
  return 1
}

# Wait for AWS credentials
if ! check_aws_credentials; then
  echo "Failed to obtain AWS credentials"
  exit 1
fi

# Fetch secrets with retry
if ! fetch_secrets; then
  echo "Failed to fetch secrets"
  exit 1
fi


# Create .env file only if we have all required variables
if [ -n "$DB_USERNAME" ] && [ -n "$DB_PASSWORD" ] && [ -n "$DB_HOST" ]; then
  cat <<EOT > /home/ubuntu/webapp/.env
PORT="${var.application_port}"
DATABASE_NAME="${var.db_name}"
DATABASE_USER=$DB_USERNAME
DATABASE_PASSWORD=$DB_PASSWORD
DATABASE_HOST=$DB_HOST
DATABASE_DIALECT="mysql"
NODE_ENV="production"
S3_BUCKET_NAME="${var.s3_bucket_name}"
AWS_REGION="${var.AWS_REGION}"
STATSD_PORT="8125"
SNS_TOPIC_ARN="${var.sns_arn}"
JWT_SECRET="${var.JWT_SECRET}"
EOT
else
  echo "Missing required credentials"
  exit 1
fi

# Set up logs
mkdir -p /home/ubuntu/webapp/logs
sudo touch /home/ubuntu/webapp/logs/app.log
sudo chmod 664 /home/ubuntu/webapp/logs/app.log
sudo chown ubuntu:ubuntu /home/ubuntu/webapp/logs/app.log

# Start CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/cloudwatch-config.json \
  -s

# Restart webapp service
sudo systemctl enable webapp.service
sudo systemctl daemon-reload
sudo systemctl restart webapp.service

echo "User data script completed successfully"
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
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_target_group.arn
  }
}

resource "aws_lb_listener" "web_app_http_listener" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# Attach Target Group to Auto Scaling Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
  lb_target_group_arn    = aws_lb_target_group.web_app_target_group.arn
}

