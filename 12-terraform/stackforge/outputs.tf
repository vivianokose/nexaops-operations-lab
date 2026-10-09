output "vpc_id" {
  description = "StackForge VPC ID"
  value       = module.networking.vpc_id
}

output "app_server_public_ips" {
  description = "Public IPs of the app servers"
  value       = module.compute.public_ip_addresses
}

output "db_endpoint" {
  description = "RDS connection endpoint"
  value       = module.database.db_endpoint
  sensitive   = true
}

output "s3_bucket_name" {
  description = "Assets bucket name"
  value       = module.storage.bucket_name
}
