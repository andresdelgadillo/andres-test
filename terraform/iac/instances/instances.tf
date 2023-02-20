
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.s3_bucket}"
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
  source                = "../../modules/instance"
  environment           = var.environment
  vpc_id                = data.terraform_remote_state.vpc.outputs.network_vpc_1.id
  security_group_alb_id = data.terraform_remote_state.vpc.outputs.load_balancer_sg_1.id
  app_name              = var.app_name
  private_subnets       = local.pvt_subnets_list1
  desired_capacity      = var.instances.desired_capacity
  max_size              = var.instances.max_size
  min_size              = var.instances.min_size
  target_group_arn      = [data.terraform_remote_state.vpc.outputs.load_balancer_tg_1.arn]

  providers = {
    aws = aws.region_1
  }
}
