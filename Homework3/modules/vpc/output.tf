# VPC OUTPUT

output "opsschool_vpc" {
    value = aws_vpc.opsschool_vpc.*.id
}

output "opsschool_igw" {
    value = aws_internet_gateway.opsschool_igw.id
}

output "public_sub" {
    value = aws_subnet.public_sub.*.id
}

output "private_sub" {
    value = aws_subnet.private_sub.*.id
}

output "opsschool_eip" {
    value = aws_eip.opsschool_eip.*.id
}

output "opsschool_natgw" {
    value = aws_nat_gateway.opsschool_natgw.*.id
}

output "opsschool_rt_privatesub" {
    value = aws_route_table.opsschool_rt_privatesub.*.id
}

output "opsschool_rt_publicsub" {
    value = aws_route_table.opsschool_rt_publicsub.*.id
}

output "nginx_sg" {
    value = aws_security_group.nginx_sg.id
}

output "db_sg" {
    value = aws_security_group.db_sg.id
}

output "elb_dns_name" {
    value = aws_elb.opsschool_elb.dns_name
}