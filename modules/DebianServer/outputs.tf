output "public_ip" {
    value = aws_eip.eip.address
}
output "cidr_block" {
    value = aws_vpc.vpc.cidr_block
}
output "security_group_id" {
    value = aws_security_group.security_group.id
}