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