resource "aws_iam_policy" "s3_read" {
  name = "clearops-tf-s3-read"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:ListBucket"]
      Resource = [
        "arn:aws:s3:::stackforge-assets-948102249482-dev",
        "arn:aws:s3:::stackforge-assets-948102249482-dev/*"
      ]
    }]
  })
}

module "clearops_api_iam" {
  source          = "./modules/app-iam"
  cluster_name    = module.eks.cluster_name
  namespace       = "default"
  service_account = "clearops-api"
  policy_arns     = [aws_iam_policy.s3_read.arn]
}

output "app_iam_role_arn" { value = module.clearops_api_iam.role_arn }
