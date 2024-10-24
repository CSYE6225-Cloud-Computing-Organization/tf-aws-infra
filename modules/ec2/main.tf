resource "aws_security_group" "application_security_group" {
  vpc_id = var.vpc_id

  name        = "application security group"
  description = "Security group for EC2 instances hosting web applications"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.common_cidr_block]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.common_cidr_block]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.common_cidr_block]
  }

  ingress {
    description = "Allow application port"
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = "tcp"
    cidr_blocks = [var.common_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.common_cidr_block]
  }

  tags = {
    Name = "application security group"
  }
}

# EC2 Instance
resource "aws_instance" "web_app_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.application_security_group.id]

  user_data = <<-EOF
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
  EOT

  # Check if webapp.service exists and restart the service
    if systemctl list-units --full -all | grep -Fq 'webapp.service'; then
      sudo systemctl enable webapp.service
      sudo systemctl daemon-reload
      sudo systemctl restart webapp.service
    fi
  EOF



  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }

  tags = {
    Name = "webapp"
  }

}

