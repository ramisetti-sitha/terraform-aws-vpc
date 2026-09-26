resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    instance_tenancy = "default"
    tags = local.vpc_final_tags
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id #VPC association
    tags = local.igw_final_tags
}

resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidr)
    vpc_id =aws_vpc.main.id
    cidr_block = var.public_subnet_cidr[count.index]
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = true
    tags= merge(
        local.common_tags,
        # roboshop-dev-public-us-east-1a
        {
            Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
        },
        var.public_subnet_tags
    )

}