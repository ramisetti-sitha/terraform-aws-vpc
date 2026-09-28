output "azs_info" {
    value = data.aws_availability_zones.available
}

output "default_vpc_info" {
    value = data.aws_vpc.default
}

output "default_route_table_info" {
    value = data.aws_route_table.default
}