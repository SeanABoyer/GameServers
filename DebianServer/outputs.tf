output "public_ip" {
    value = aws_eip.eip.address
}