variable "environment" {
    description = "Environment name prefix"
    type = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "vpc" {
  description = "VPC in which the LB security group and target group be created"
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the LB"
}

variable "allowed_cidr" {
  description = "CIDR list which is allowed as inbound in ALB security group"
  type        = list(string)
}

variable "internal" {
    description = "If true, the LB will be internal"
    type = bool
    default = true
}
