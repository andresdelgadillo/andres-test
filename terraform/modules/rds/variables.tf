variable "environment" {
    description = "Environment name prefix"
    type = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID in which the RDS be created"
  type        = string
}

variable "security_group_ec2_id" {
    description = "Security group ID to allow access from/to"
    type        = string
}

variable "private_subnets_rds" {
  description = "A list of subnet IDs to be used by the RDS"
  type        = list(string)  
}

variable "multi_az" {
    description = "Specifies if the RDS instance is multi-AZ"
    type = bool
    default = false
}
variable "instance_class" {
    description = "The RDS instance class"
    type        = string
}
