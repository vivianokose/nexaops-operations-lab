data "aws_caller_identity" "current" {}

module "networking" {
  source      = "./modules/networking"
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}

module "compute" {
  source            = "./modules/compute"
  environment       = var.environment
  public_subnet_ids = module.networking.public_subnet_ids
  app_sg_id         = module.networking.app_sg_id
}

module "database" {
  source             = "./modules/database"
  environment        = var.environment
  private_subnet_ids = module.networking.private_subnet_ids
  db_sg_id           = module.networking.db_sg_id
  db_username        = var.db_username
  db_password        = var.db_password
}

module "storage" {
  source         = "./modules/storage"
  environment    = var.environment
  aws_account_id = data.aws_caller_identity.current.account_id
}
