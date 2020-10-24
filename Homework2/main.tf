# PROVIDER

provider "aws" {
    region = var.aws_region
}

# DATA

data "aws_availability_zones" "available" {

}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# RESOURCES

resource "aws_vpc" "opsschool_vpc" {
    cidr_block = "10.10.0.0/16"
    tags = {
        "Name" = "opsschool_vpc"
    }
}

resource "aws_internet_gateway" "opsschool_igw" {
    vpc_id = aws_vpc.opsschool_vpc.id
    tags = {
        "Name" = "opsschool_igw"
    }
}

resource "aws_subnet" "private_sub" {
    count = 2
    vpc_id = aws_vpc.opsschool_vpc.id
    availability_zone = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true
    cidr_block = "10.10.${10+count.index}.0/24"
    tags = {
        "Name" = "private_sub_az${count.index}"
    }
}

resource "aws_subnet" "public_sub" {
    count = 2
    vpc_id = aws_vpc.opsschool_vpc.id
    availability_zone = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true
    cidr_block = "10.10.${20+count.index}.0/24"
    tags = {
        "Name" = "public_sub_az${count.index}"
    }
}

resource "aws_eip" "opsschool_eip" {
    count = 2
    vpc = true
}

resource "aws_nat_gateway" "opsschool_natgw" {
    count = 2
    allocation_id = aws_eip.opsschool_eip.*.id[count.index]
    subnet_id = aws_subnet.public_sub.*.id[count.index]
    tags = {
        "Name" = "opsschool_natgw_az${count.index}"
    }
}

resource "aws_route_table" "opsschool_rt_privatesub" {
    count = 2
    vpc_id = aws_vpc.opsschool_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.opsschool_natgw.*.id[count.index]
    }
    tags = {
        "Name" = "opsschool_rt_privatesub${count.index}"
    }
}

resource "aws_route_table" "opsschool_rt_publicsub" {
    count = 2
    vpc_id = aws_vpc.opsschool_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.opsschool_igw.id
    }
    tags = {
        "Name" = "opsschool_rt_publicsub${count.index}"
    }
}

resource "aws_route_table_association" "associate_route_private_sub" {
    count = 2
    subnet_id = aws_subnet.private_sub.*.id[count.index]
    route_table_id = aws_route_table.opsschool_rt_privatesub.*.id[count.index]
}

resource "aws_route_table_association" "associate_route_public_sub" {
    count = 2
    subnet_id = aws_subnet.public_sub.*.id[count.index]
    route_table_id = aws_route_table.opsschool_rt_publicsub.*.id[count.index]
}

resource "aws_security_group" "nginx_sg" {
  name        = "nginx_opsschhol-sg"
  description = "Allow HTTPS and SSH for nginx server"
  vpc_id      = aws_vpc.opsschool_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db_opsschhol-sg"
  description = "allow ssh from internal net only"
  vpc_id      = aws_vpc.opsschool_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb_sg" {
  name        = "elb_opsschhol-sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.opsschool_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "opsschool_elb" {
    name = "opsschool-elb"
    security_groups = [aws_security_group.elb_sg.id]
    subnets = aws_subnet.public_sub.*.id
    instances = aws_instance.nginx.*.id

    listener {
      instance_port     = 80
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    }

    health_check {
      target              = "HTTP:80/"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5 
    }
}


resource "aws_instance" "nginx" {
    count                  = 2
    subnet_id              = aws_subnet.public_sub.*.id[count.index]
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = "t2.micro"
    key_name               = var.key_name
    vpc_security_group_ids = [aws_security_group.nginx_sg.id]
    user_data              = file("nginx.sh")
    tags = {
        Name = "opsschool-ec2-nginx_${count.index}"
        purpose = "opsschool learning"
        owner = "Roee Fabrikant"
  }
}

resource "aws_instance" "db" {
    count                  = 2
    subnet_id              = aws_subnet.private_sub.*.id[count.index]
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = "t2.micro"
    key_name               = var.key_name
    vpc_security_group_ids = [aws_security_group.db_sg.id]
    tags = {
        Name = "opsschool-ec2-db_${count.index}"
        purpose = "opsschool learning"
        owner = "Roee Fabrikant"
  }
}

