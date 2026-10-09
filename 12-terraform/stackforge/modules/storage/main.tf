resource "aws_s3_bucket" "assets" {
  bucket        = "stackforge-assets-${var.aws_account_id}-${var.environment}"
  force_destroy = true
  tags          = { Name = "stackforge-assets-${var.environment}" }
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket                  = aws_s3_bucket.assets.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
