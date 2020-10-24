output "nginx_webserver_public_address" {
    value = aws_instance.nginx.*.public_ip
}

output "database_public_address" {
    value = aws_instance.db.*.public_ip
}

output "loadbalancer_dns_name" {
    value = aws_elb.opsschool_elb.*.dns_name
}
