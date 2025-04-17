provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "../modules/network"
  name                  = var.name
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs_1    = var.public_subnet_cidrs_1
  public_subnet_cidrs_2    = var.public_subnet_cidrs_2
  private_subnet_cidrs  = var.private_subnet_cidrs
  azs                   = var.azs
}
