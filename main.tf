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

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr[count.index]
    availability_zone = local.az_names[count.index]
    tags = merge(
        local.common_tags,
        {
            Name="${var.project}-${var.environment}-private-${local.az_names[count.index]}"
        },
        var.private_subnet_tags
    )
}

resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_subnet_cidr[count.index]
    availability_zone = local.az_names[count.index]
    tags = merge(
        local.common_tags,
        {
            Name="${var.project}-${var.environment}-database-${local.az_names[count.index]}"
        },
        var.database_subnet_tags
    )
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id 
    tags = merge (
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        },
        var.public_route_table_tags
    )
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id 
    tags = merge (
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        },
        var.private_route_table_tags
    )
}

resource "aws_route_table" "database" {
    vpc_id = aws_vpc.main.id 
    tags = merge (
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        },
        var.database_route_table_tags
    )
}

resource "aws_eip" "nat" {
     domain= "vpc"
     tags = merge(
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-nat"
        },
        var.eip_tags
     )

}


resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public[0].id
    tags = merge (
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        },
        var.nat_gateway_tags
    )
    depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table_association" "public"{
    count = length(var.public_subnet_cidr)
    subnet_id = var.public_subnet_cidr[count.index].id
    route_table_id = aws_route_table.public.id 
}

resource "aws_route_table_association" "database"{
    count = length(var.database_subnet_cidr)
    subnet_id = var.database_subnet_cidr[count.index].id
    route_table_id = aws_route_table.database.id 
}

resource "aws_route_table_association" "private"{
    count = length(var.private_subnet_cidr)
    subnet_id = var.private_subnet_cidr[count.index].id
    route_table_id = aws_route_table.private.id 
}

resource "aws_route" "private" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "database" {
    route_table_id = aws_route_table.database.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
}

