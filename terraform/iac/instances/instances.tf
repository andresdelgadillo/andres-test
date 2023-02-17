
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.config.s3_bucket}"
    key    = "env:/${terraform.workspace}/terraform-states/networking/tfstate"
    region = "us-west-2"
  }
}

locals {
  # List of private subnets IDs
  pvt_subnets_list1 = [for v in values("${data.terraform_remote_state.vpc.outputs.network_vpc_1_subnets_pvt}") : v.id if can(v.id)]
  pub_subnets_list1 = [for v in values("${data.terraform_remote_state.vpc.outputs.network_vpc_1_subnets_pub}") : v.id if can(v.id)]
}

module "instance_1" {
  source             = "../../modules/instance"
  environment        = var.config.environment
  vpc                = data.terraform_remote_state.vpc.outputs.network_vpc_1
  security_group_alb = data.terraform_remote_state.vpc.outputs.load_balancer_sg_1
  app_name           = var.config.app_name
  private_subnets    = local.pvt_subnets_list1
  desired_capacity   = var.config.instances.desired_capacity
  max_size           = var.config.instances.max_size
  min_size           = var.config.instances.min_size
  target_group       = data.terraform_remote_state.vpc.outputs.load_balancer_tg_1

  providers = {
    aws = aws.region_1
  }
}
