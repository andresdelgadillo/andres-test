variable "vpc_name" {
    description = "VPC name"
    type = string
}
variable "vpc_cidr" {
    description = "The IPv4 CIDR block for the VPC"
    type = string
}
variable "subnets" {
    description = "Parameter to create the subnets"
    type = map
}
