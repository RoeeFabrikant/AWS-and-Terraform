# WEB-SERVER OUTPUT

output "nginx_webserver_public_address" {
    value = aws_instance.nginx.*.public_ip
}

output "nginx_id" {
    value = aws_instance.nginx.*.id
    description = "The ID of the nginx instances"
}

output "s3_log_bucket_id" {
    value = aws_s3_bucket.opsschool_s3_bucket.id
}
