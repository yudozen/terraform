terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    assume_role {
        role_arn = "arn:aws:iam::${var.account_id}:role/terraform_pike_20240215070731337300000002"
    }
}

resource "aws_s3_bucket" "example" {
    bucket = "dzn-tf-test-bucket"
}
