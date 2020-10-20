# VARIABLES

variable "resource_owner" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {
  default = "us-east-1"
}
variable "ec2_count" {
    default = 2
}

# PROVIDER

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

#DATA

data "aws_ami" "ubuntu_1804" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200908"]
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

resource "aws_ebs_volume" "data_vol" {
    count = var.ec2_count
    availability_zone = "us-east-1a"
    type = "gp2"
    size = 10
    encrypted = true
    tags = {
        Name = "opsschool-data-vol-${count.index}"
        purpose = "opsschool"
    }
}   

resource "aws_volume_attachment" "data_vol" {
    count = var.ec2_count
    device_name = "/dev/sdh"
    volume_id   = element(aws_ebs_volume.data_vol.*.id, count.index)
    instance_id = element(aws_instance.nginx.*.id, count.index)
}

resource "aws_instance" "nginx" {
    count                  = var.ec2_count
    ami                    = data.aws_ami.ubuntu_1804.id
    availability_zone      = "us-east-1a"
    instance_type          = "t2.medium"
    key_name               = var.key_name
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
    tags = {
        Name = "opsschool-ec2-nginx_${count.index}"
        purpose = "opsschool learning"
        owner = var.resource_owner
  }


    provisioner "remote-exec" {
        connection {
            type        = "ssh"
            host        = self.public_ip
            user        = "ubuntu"
            private_key = file(var.private_key_path)
        }

        inline = [
            "sudo apt update --yes",
            "sudo apt install nginx --yes",
            "sudo chmod 646 /var/www/html/index.nginx-debian.html",
            "sudo echo 'OpsSchool Rules' > '/var/www/html/index.nginx-debian.html'",
            "sudo chmod 644 /var/www/html/index.nginx-debian.html",
            "sudo service nginx start"
            ]
     }
}

#OUTPUT

output "aws_instance_public_dns" {
  value = aws_instance.nginx.*.public_dns
}
