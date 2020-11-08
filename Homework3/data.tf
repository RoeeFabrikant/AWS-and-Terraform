
data "aws_availability_zones" "available" {
}

data "template_file" "sh_nginx" {
  template = file("nginx.sh")
  vars = {
    s3_webserver_log_id = module.nginx.s3_log_bucket_id
  }
}
