provider "aws" {
  region = var.aws_region
}

module "network" {
  source               = "./network"
  name                 = var.branch_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs_1  = var.public_subnet_cidrs_1
  public_subnet_cidrs_2  = var.public_subnet_cidrs_2
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

module "service" {
  source             = "./modules/service"
  app_name           = var.app_name
  branch_name        = var.branch_name
  domain_name        = var.domain_name
  vpc_id             = module.network.vpc_id
  public_subnets     = module.network.public_subnets
  private_subnets    = module.network.private_subnets
  security_group_id  = module.network.security_group_id
  hosted_zone_id     = var.hosted_zone_id
  container_image    = var.container_image
  destroy_after_secs = var.destroy_after_secs
}

terraform {
  backend "s3" {}
}