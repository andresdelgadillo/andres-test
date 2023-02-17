terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend "s3" {
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = var.config.aws_region_1
  alias  = "region_1"
  default_tags {
    tags = {
      product-family   = "${var.config.tags.product-family}"
      application-name = "${var.config.tags.application-name}"
      account-name     = "${var.config.tags.account-name}"
      environment      = "${var.config.tags.environment}"
      managed-by       = "${var.config.tags.managed-by}"
    }
  }
}
