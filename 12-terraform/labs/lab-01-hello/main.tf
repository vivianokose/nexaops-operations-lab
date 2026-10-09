terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project = "stackforge"
      Owner   = "vivian"
      Module  = "12"
      Managed = "terraform"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "hello" {
  bucket = "stackforge-tf-hello-${random_id.suffix.hex}"
}

output "bucket_name" {
  value = aws_s3_bucket.hello.id
}
