
output "nginx_webserver_public_address" {
    value = module.nginx.nginx_webserver_public_address
}

output "db_server_public_address" {
  value = module.db.database_public_address
}

output "elb_dns_name" {
  value = module.vpc.elb_dns_name
}

#output metadata {
#  value = data.template_file.sh_nginx.rendered
#}
