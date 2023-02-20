
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.s3_bucket}"
    key    = "env:/${terraform.workspace}/terraform-states/networking/tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "ec2" {
  backend = "s3"
  config = {
    bucket = "${var.s3_bucket}"
    key    = "env:/${terraform.workspace}/terraform-states/instances/tfstate"
    region = "us-west-2"
  }
}

locals {
  # List of private RDS subnets IDs
  pvt_subnets_rds_list1 = [for v in values("${data.terraform_remote_state.vpc.outputs.network_vpc_1_subnets_pvt_rds}") : v.id if can(v.id)]
}


module "rds_1" {
  source                = "../../modules/rds"
  environment           = var.environment
  app_name              = var.app_name
  vpc_id                = data.terraform_remote_state.vpc.outputs.network_vpc_1.id
  security_group_ec2_id = data.terraform_remote_state.ec2.outputs.instance_sg_1.id
  private_subnets_rds   = local.pvt_subnets_rds_list1
  multi_az              = var.rds.multi_az
  instance_class        = var.rds.instance_class

  providers = {
    aws = aws.region_1
  }
}
