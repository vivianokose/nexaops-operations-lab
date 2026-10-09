resource "aws_db_subnet_group" "main" {
  name       = "stackforge-db-subnet-group-${var.environment}"
  subnet_ids = var.private_subnet_ids
  tags       = { Name = "stackforge-db-subnet-group-${var.environment}" }
}

resource "aws_db_instance" "main" {
  identifier              = "stackforge-db-${var.environment}"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_name                 = "stackforge"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [var.db_sg_id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 1
  deletion_protection     = false
  tags                    = { Name = "stackforge-db-${var.environment}" }
}
