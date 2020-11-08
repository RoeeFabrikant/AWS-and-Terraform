resource "aws_vpc" "opsschool_vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        "Name" = "${var.project_name}_vpc"
    }
}

resource "aws_internet_gateway" "opsschool_igw" {
    vpc_id      = aws_vpc.opsschool_vpc.id
    tags        = {
        "Name"  = "${var.project_name}_igw"
    }
}

resource "aws_subnet" "private_sub" {
    count                   = length(var.private_subnet_cidr)
    vpc_id                  = aws_vpc.opsschool_vpc.id
    availability_zone       = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true
    cidr_block              = var.private_subnet_cidr[count.index]
    tags = {
        "Name" = "${var.project_name}_private_sub_az${count.index}"
    }
}

resource "aws_subnet" "public_sub" {
    count                   = length(var.public_subnet_cidr)
    vpc_id                  = aws_vpc.opsschool_vpc.id
    availability_zone       = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true
    cidr_block              = var.public_subnet_cidr[count.index]
    tags = {
        "Name" = "${var.project_name}_public_sub_az${count.index}"
    }
}

resource "aws_eip" "opsschool_eip" {
    count = length(var.public_subnet_cidr)
    vpc   = true
}

resource "aws_nat_gateway" "opsschool_natgw" {
    count           = length(var.public_subnet_cidr)
    allocation_id   = aws_eip.opsschool_eip.*.id[count.index]
    subnet_id       = aws_subnet.public_sub.*.id[count.index]
    tags = {
        "Name" = "${var.project_name}_natgw_az${count.index}"
    }
}

resource "aws_route_table" "opsschool_rt_privatesub" {
    count     = length(var.private_subnet_cidr)
    vpc_id    = aws_vpc.opsschool_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.opsschool_natgw.*.id[count.index]
    }
    tags = {
        "Name" = "${var.project_name}_rt_privatesub${count.index}"
    }
}

resource "aws_route_table" "opsschool_rt_publicsub" {
    count           = length(var.public_subnet_cidr)
    vpc_id          = aws_vpc.opsschool_vpc.id
    route {
        cidr_block  = "0.0.0.0/0"
        gateway_id  = aws_internet_gateway.opsschool_igw.id
    }
    tags = {
        "Name" = "${var.project_name}_rt_publicsub${count.index}"
    }
}

resource "aws_route_table_association" "associate_route_private_sub" {
    count             = length(var.private_subnet_cidr)
    subnet_id         = aws_subnet.private_sub.*.id[count.index]
    route_table_id    = aws_route_table.opsschool_rt_privatesub.*.id[count.index]
}

resource "aws_route_table_association" "associate_route_public_sub" {
    count             = length(var.public_subnet_cidr)
    subnet_id         = aws_subnet.public_sub.*.id[count.index]
    route_table_id    = aws_route_table.opsschool_rt_publicsub.*.id[count.index]
}
