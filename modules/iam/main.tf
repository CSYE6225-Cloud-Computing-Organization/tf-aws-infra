# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the AWS managed CloudWatch Agent policy
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Custom CloudWatch Logs and Metrics policy for EC2 instances
resource "aws_iam_policy" "custom_cloudwatch_policy" {
  name        = "CustomCloudWatchPolicy"
  description = "Policy to allow EC2 instances to create CloudWatch log groups and send logs and metrics."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_custom_cloudwatch_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.custom_cloudwatch_policy.arn
}

# S3 permissions policy for EC2 instance
resource "aws_iam_policy" "s3_policy" {
  name        = "S3KMSAccessPolicy"
  description = "Allow EC2 instances to perform basic S3 bucket operations and decrypt KMS-encrypted objects"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          var.s3_bucket_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_basic_operations" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

# Auto Scaling and Load Balancer permissions for EC2 instances
resource "aws_iam_policy" "autoscaling_policy" {
  name        = "AutoScalingInstancePolicy"
  description = "Allow EC2 instances in Auto Scaling group to describe and attach resources, and support metrics."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:PutScalingPolicy",
          "autoscaling:UpdateAutoScalingGroup",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTargetGroups"
        ],
        Resource = [
          "arn:aws:autoscaling:${var.AWS_REGION}:${var.aws_account_id}:autoScalingGroup/*",
          "arn:aws:elasticloadbalancing:${var.AWS_REGION}:${var.aws_account_id}:targetgroup/*",
          "arn:aws:elasticloadbalancing:${var.AWS_REGION}:${var.aws_account_id}:loadbalancer/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_autoscaling_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.autoscaling_policy.arn
}

# SNS permissions policy for EC2 instance
resource "aws_iam_policy" "sns_policy" {
  name        = "SNSPublishPolicy"
  description = "Allow EC2 instances to publish messages to specific SNS topics."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = [
          var.sns_topic_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_sns_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.sns_policy.arn
}


# Secrets Manager Policy
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "EC2SecretsManagerPolicy"
  description = "Allow EC2 instances to access secrets from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ],
        Resource = [
          var.db_credentials_secret_arn,
          var.lambda_email_credentials_secret_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

# KMS Full Access Policy
resource "aws_iam_policy" "kms_full_access_policy" {
  name        = "KMSFullAccessPolicy"
  description = "Allow EC2 instances to use all required KMS keys"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ],
        Resource = [
          var.ec2_key_arn,
          var.rds_key_arn,
          var.s3_key_arn,
          var.secrets_manager_key_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kms_full_access_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.kms_full_access_policy.arn
}

# RDS Access Policy
resource "aws_iam_policy" "rds_policy" {
  name        = "RDSAccessPolicy"
  description = "Allow EC2 instances to access RDS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBClusterEndpoints"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.rds_policy.arn
}

# KMS Auto Scaling Policy
resource "aws_kms_key_policy" "kms_autoscaling_policy" {
  key_id = var.ec2_key_arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowRootAccess",
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowAutoScalingService",
        Effect = "Allow",
        Principal = {
          Service = "autoscaling.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}


# Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}
