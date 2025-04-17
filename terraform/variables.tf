variable "aws_region" {
  default = "us-east-1"
}

variable "app_name" {}

variable "branch_name" {}

variable "name" {} 

variable "vpc_cidr" {}

variable "public_subnet_cidrs_1" {
  type = list(string)
}

variable "public_subnet_cidrs_2" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "domain_name" {}

variable "hosted_zone_id" {}

variable "container_image" {}

variable "destroy_after_secs" {
  default = 86400 # 24 hours in seconds
}