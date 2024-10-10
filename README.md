# tf-aws-infra
# AWS Infrastructure Setup with Terraform
This repository contains Terraform configurations to set up a basic AWS infrastructure, including VPC, subnets, and routing.

## Prerequisites

- Install Terraform on you device
- AWS CLI configured with your credentials

## Setup Instructions

1. Clone the repository

   git clone repository
   cd tf-aws-infra

Initialize Terraform

Run the following command to initialize Terraform:

terraform init

Apply the Terraform plan

To create the infrastructure, run:

terraform apply
Confirm with yes when prompted.

Destroy the infrastructure
To clean up resources, run:

terraform destroy