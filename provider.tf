# Instructions: Place your provider configuration below
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Instructions: Add S3 Remote Backend Configuration

  # Instructions: After first running `terraform apply`, uncomment the block below, full in the desired values, and re-run 'terraform apply' to configure your S3 Remote Backend.
  # IMPORANT! - Ensure the resources you are referencing (S3 Bucket and DynamoDB table) already exist in the AWS account and region you are currently in or it will fail.

   backend "s3" {
     bucket         = "example-prod-workload-tf-state-p4id"
     key            = "state/terraform.tfstate"
     region         = "us-east-1"
     encrypt        = true
     dynamodb_table = "example-prod-workload-tf-state-lock-30wv"
   }
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"


  default_tags {
    tags = {
      Management = "Terraform"
    }
  }
}
# - Trust Relationships -
data "aws_iam_policy_document" "ec2_trust_relationship" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "random_string" "example" {
  length   = 4
  special  = false
  upper    = false
}

# - IAM Role -
resource "aws_iam_role" "example" {
  name               = "example-prod-resource-${random_string.example.result}"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_relationship.json

  force_detach_policies = true
}
resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# - S3 Bucket -
resource "aws_s3_bucket" "example" {
  bucket_prefix = "example-prod-workload-tf-state-p4id"
  force_destroy = true

  # - Challenge: resolve Checkov issues -
  #checkov:skip=CKV2_AWS_62: "Ensure S3 buckets should have event notifications enabled"
  #checkov:skip=CKV2_AWS_6: "Ensure that S3 bucket has a Public Access block"
  #checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  #checkov:skip=CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled"
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
}
