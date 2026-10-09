output "instance_ids"        { value = aws_instance.app[*].id }
output "public_ip_addresses" { value = aws_instance.app[*].public_ip }
