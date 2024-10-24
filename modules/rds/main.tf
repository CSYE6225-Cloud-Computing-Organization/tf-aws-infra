resource "aws_security_group" "db_security_group" {
  name        = "db-security-group-${var.db_identifier}"
  description = "Security group for RDS instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow MySQL traffic"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-security-group"
  }
}


# RDS Instance
resource "aws_db_instance" "default" {
  allocated_storage     = 20
  storage_type          = "gp2"
  engine                = var.db_engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  identifier            = var.db_identifier
  db_name               = var.db_name
  username              = var.db_username
  password              = var.db_password
  db_subnet_group_name  = aws_db_subnet_group.default.name
  vpc_security_group_ids= [aws_security_group.db_security_group.id]
  parameter_group_name  = aws_db_parameter_group.custom.name
  skip_final_snapshot   = true
  publicly_accessible   = false
  multi_az              = false
}

# DB Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "my-db-subnet-group-${var.db_identifier}"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My DB Subnet Group"
  }
}

# DB Parameter Group
resource "aws_db_parameter_group" "custom" {
  name   = "custom-db-parameter-group-${var.db_identifier}"
  family = "${var.db_engine}${var.engine_version}"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
    apply_method = "immediate"
  }

}
