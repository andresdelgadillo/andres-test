
module "network_vpc_1" {
  source   = "../../modules/network"
  vpc_name = var.app_name
  vpc_cidr = var.vpc_1.cidr
  subnets  = var.vpc_1.subnets
  providers = {
    aws = aws.region_1
  }
}

module "load_balancer_1" {
  source       = "../../modules/alb"
  environment  = var.environment
  app_name     = var.app_name
  vpc          = module.network_vpc_1.vpc
  subnets      = module.network_vpc_1.subnets_pub
  allowed_cidr = var.allowed_cidr
  internal     = false

  providers = {
    aws = aws.region_1
  }
}
