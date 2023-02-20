
variable "tags" {
  description = "Values to tag all the resources"
  type        = map(any)
}

variable "aws_region_1" {
  description = "AWS region to deploy the infrastructure"
  type        = string
}

variable "aws_account" {
  description = "AWS region to deploy the infrastructure"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket to store the Terrraform states"
  type        = string
}

variable "s3_key" {
  description = "S3 path to store the Terraform state files"
  type        = string
}

variable "dynamodb_table" {
  description = "DynamoDB table name to store the Terraform state files"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR list which is allowed as inbound in ALB security group"
  type        = list(string)
}

variable "vpc_1" {
  description = "Parameters to create the VPC"
}

variable "instances" {
  description = "Parameters to create the EC2 instances"
  type        = map(any)
}

variable "rds" {
  description = "Parameters to create the RDS"
  type        = map(any)
}
