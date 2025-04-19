variable "app_name" {}

variable "branch_name" {}

variable "container_image" {}

variable "private_subnets" {
  type = list(string)
}

variable "security_group_id" {}

variable "destroy_after_secs" {}

variable "public_subnets" {
  type = list(string)
}

variable "vpc_id" {}

variable "domain_name" {}

variable "hosted_zone_id" {}