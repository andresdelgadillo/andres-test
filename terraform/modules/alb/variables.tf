variable "environment" {
    description = "Environment Prefix"
    type = string
}
variable "app_name" {}
variable "vpc" {}
variable "subnets" {}
variable "allowed_cidr" {}
variable "internal" {
    description = ""
    type = bool
    default = true
}
