module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "security_groups" {
  source       = "./modules/security-groups"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "kms" {
  source       = "./modules/kms"
  project_name = var.project_name
}
module "s3" {
  source = "./modules/s3"

  project_name = var.project_name

  kms_key_arn = module.kms.kms_key_arn
}

module "iam" {
  source = "./modules/iam"

  project_name          = var.project_name
  raw_bucket_name       = module.s3.raw_bucket_name
  processed_bucket_name = module.s3.processed_bucket_name
  kms_key_arn           = module.kms.kms_key_arn
}

module "alb" {

  source = "./modules/alb"

  project_name = var.project_name

  vpc_id = module.vpc.vpc_id

  public_subnet_ids = module.vpc.public_subnet_ids

  alb_security_group_id = module.security_groups.alb_sg_id
}

module "compute" {

  source = "./modules/compute"

  project_name = var.project_name

  private_subnet_ids = module.vpc.private_subnet_ids

  web_sg_id = module.security_groups.web_sg_id

  app_sg_id = module.security_groups.app_sg_id

  target_group_arn = module.alb.web_target_group_arn

  app_instance_profile_name = module.iam.app_instance_profile_name
}

module "cloudwatch" {

  source = "./modules/cloudwatch"

  project_name = var.project_name

  alb_name = module.alb.alb_name
}