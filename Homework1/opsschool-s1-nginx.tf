# VARIABLES

variable "resource_owner" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {
  default = "us-east-1"
}

# PROVIDERS

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

# DATA

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# RESOURCES

resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "allow_ssh" {
  name        = "nginx_opsschhol-sg"
  description = "Allow HTTPS and SSH for nginx server"
  vpc_id      = aws_default_vpc.default.id

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

resource "aws_instance" "nginx" {
  ami                    = data.aws_ami.aws-linux.id
  availability_zone      = "us-east-1a"
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "opsschool-ec2-nginx"
    purpose = "opsschool learning"
    owner = var.resource_owner
  }
}

resource "aws_instance" "nginx2" {
  ami                    = data.aws_ami.aws-linux.id
  availability_zone      = "us-east-1a"
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "opsschool-ec2-nginx2"
    purpose = "opsschool learning"
    owner = var.resource_owner
  }
}

resource "aws_ebs_volume" "data_vol1" {
  availability_zone = "us-east-1a"
  type = "gp2"
  size = 10
  encrypted = true
  tags = {
    Name = "opsschool-data-vol1"
    purpose = "opsschool"
  }
}

resource "aws_ebs_volume" "data_vol2" {
  availability_zone = "us-east-1a"
  type = "gp2"
  size = 10
  encrypted = true
  tags = {
    Name = "opsschool-data-vol2"
    purpose = "opsschool"
  }
}

resource "aws_volume_attachment" "data_vol1" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.data_vol1.id
  instance_id = aws_instance.nginx.id
}

resource "aws_volume_attachment" "data_vol2" {
    device_name = "/dev/sdh"
    volume_id   = aws_ebs_volume.data_vol2.id
    instance_id = aws_instance.nginx2.id
    
    provisioner "remote-exec" {
        connection {
            type        = "ssh"
            host        = aws_instance.nginx.public_ip
            user        = "ec2-user"
            private_key = file(var.private_key_path)
        }

        inline = [
            "sudo yum install nginx -y",
            "sudo chmod 646 /usr/share/nginx/html/index.html",
            "sudo echo 'OpsSchool Rules' > '/usr/share/nginx/html/index.html'",
            "sudo chmod 644 /usr/share/nginx/html/index.html",
            "sudo service nginx start"
            ]
     }

    provisioner "remote-exec" {
        connection {
            type        = "ssh"
            host        = aws_instance.nginx2.public_ip
            user        = "ec2-user"
            private_key = file(var.private_key_path)
        }

        inline = [
            "sudo yum install nginx -y",
            "sudo chmod 646 /usr/share/nginx/html/index.html",
            "sudo echo 'OpsSchool Rules' > '/usr/share/nginx/html/index.html'",
            "sudo chmod 644 /usr/share/nginx/html/index.html",
            "sudo service nginx start"
            ]
     }
}

# OUTPUT

output "aws_instance_public_dns" {
  value = aws_instance.nginx.public_dns
}

output "aws_instance_public_dns1" {
  value = aws_instance.nginx2.public_dns
}
