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