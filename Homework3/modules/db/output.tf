# WEB-SERVER OUTPUT

output "database_public_address" {
    value = aws_instance.db.*.public_ip
}
