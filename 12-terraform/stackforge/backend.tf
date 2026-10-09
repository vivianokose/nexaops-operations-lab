terraform {
  backend "s3" {
    bucket         = "stackforge-terraform-state-948102249482"
    key            = "stackforge/production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "stackforge-terraform-locks"
  }
}
