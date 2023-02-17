
# OUTPUTS

output "network_vpc_1" {
  value = module.network_vpc_1.vpc
}

output "network_vpc_1_subnets_pvt" {
  value = module.network_vpc_1.subnets_pvt
}

output "network_vpc_1_subnets_pvt_rds" {
  value = module.network_vpc_1.subnets_pvt_rds
}

output "network_vpc_1_subnets_pub" {
  value = module.network_vpc_1.subnets_pub
}

output "route_table_pvt_1" {
  value = module.network_vpc_1.route_table_pvt
}

output "load_balancer_sg_1" {
  value = module.load_balancer_1.alb_sg
}

output "load_balancer_1" {
  value = module.load_balancer_1.aws_alb
}

output "load_balancer_tg_1" {
  value = module.load_balancer_1.alb_tg
}
