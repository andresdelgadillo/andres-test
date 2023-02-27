
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = var.aws_region_1
  default_tags {
    tags = {
      product-family   = "${var.tags.product-family}"
      application-name = "${var.tags.application-name}"
      account-name     = "${var.tags.account-name}"
      environment      = "${var.tags.environment}"
      managed-by       = "${var.tags.managed-by}"
    }
  }
}

