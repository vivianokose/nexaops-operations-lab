terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" { region = "us-east-1" }

resource "aws_s3_bucket" "drift_test" {
  bucket = "stackforge-drift-test-948102249482"
}
