
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.config.s3_bucket}"
    key    = "env:/${terraform.workspace}/terraform-states/networking/tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "ec2" {
  backend = "s3"
  config = {
    bucket = "${var.config.s3_bucket}"
    key    = "env:/${terraform.workspace}/terraform-states/instances/tfstate"
    region = "us-west-2"
  }
}

locals {
  # List of private RDS subnets IDs
  pvt_subnets_rds_list1 = [for v in values("${data.terraform_remote_state.vpc.outputs.network_vpc_1_subnets_pvt_rds}") : v.id if can(v.id)]
}


module "rds_1" {
  source              = "../../modules/rds"
  environment         = var.config.environment
  app_name            = var.config.app_name
  vpc                 = data.terraform_remote_state.vpc.outputs.network_vpc_1
  security_group_ec2  = data.terraform_remote_state.ec2.outputs.instance_sg_1
  private_subnets_rds = local.pvt_subnets_rds_list1
  multi_az            = var.config.rds.multi_az
  instance_class      = var.config.rds.instance_class

  providers = {
    aws = aws.region_1
  }
}
