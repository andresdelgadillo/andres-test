variable "vpc_id" {
  description = "VPC in which the EC2 security group be created"
  type        = string
}

variable "environment" {
  description = "Environment name prefix"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "private_subnets" {
  description = "A list of subnet IDs to be used by the autoscaling group"
  type        = list(string)
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  type        = string
  default     = "2"
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = string
  default     = "4"
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = string
  default     = "2"
}

variable "security_group_alb_id" {
  description = "Security group id to allow access from"
  type        = string
}

variable "target_group_arn" {
  description = "List of aws_alb_target_group ARNs, for use with Application Load Balancing"
  type        = list(string)
}
