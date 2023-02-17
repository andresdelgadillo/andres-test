
output "vpc" {
  value = aws_vpc.vpc
}


output "aws_region" {
  value = data.aws_region.current.name
}

output "route_table_pvt" {
  value = aws_route_table.route_table_pvt
}

output "route_table_pvt_rds" {
  value = aws_route_table.route_table_pvt_rds
}

output "route_table_pub" {
  value = aws_route_table.route_table_pub
}

output "subnets_pvt" {
  value = aws_subnet.subnet_pvt
}

output "subnets_pvt_rds" {
  value = aws_subnet.subnet_pvt_rds
}

output "subnets_pub" {
  value = aws_subnet.subnet_pub
}
