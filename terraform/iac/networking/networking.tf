
module "network_vpc_1" {
  source   = "../../modules/network"
  vpc_name = var.config.app_name
  vpc_cidr = var.config.vpc_1.cidr
  subnets  = var.config.vpc_1.subnets
  providers = {
    aws = aws.region_1
  }
}

module "load_balancer_1" {
  source       = "../../modules/alb"
  environment  = var.config.environment
  app_name     = var.config.app_name
  vpc          = module.network_vpc_1.vpc
  subnets      = module.network_vpc_1.subnets_pub # "${local.pub_subnets_list1}"
  allowed_cidr = var.config.allowed_cidr
  internal     = false

  providers = {
    aws = aws.region_1
  }
}