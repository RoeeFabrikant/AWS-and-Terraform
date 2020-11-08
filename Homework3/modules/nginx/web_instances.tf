
resource "aws_instance" "nginx" {
    count                  = var.num_of_web_servers
    subnet_id              = var.public_sub_id[count.index%2]
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = var.web_servers_intance_type
    key_name               = var.intances_private_key_name
    vpc_security_group_ids = [var.web_server_sg]
    iam_instance_profile   = aws_iam_instance_profile.iam_role_s3_write_profile.name
    user_data              = data.template_file.sh_nginx.rendered
    tags = {
        Name    = "${var.project_name}-ec2-nginx_${count.index}"
        purpose = "${var.project_name} learning"
        owner   = var.owner_name
  }
}

