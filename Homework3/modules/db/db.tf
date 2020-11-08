# DATABASE INSTANCES

resource "aws_instance" "db" {
    count                     = var.num_of_db_servers
    subnet_id                 = var.private_subnet_id[count.index%2]
    ami                       = data.aws_ami.ubuntu.id
    instance_type             = var.db_servers_intance_type
    key_name                  = var.intances_private_key_name
    vpc_security_group_ids    = [var.db_server_sg]
    tags = {
        Name    = "${var.project_name}-ec2-db_${count.index}"
        purpose = "${var.project_name} learning"
        owner   = var.owner_name
  }
}
