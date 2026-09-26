resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    instance_tenancy = "default"
    tags = local.vpc_final_tags
}