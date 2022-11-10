output "public_ip" {
    value = aws_eip.eip.public_ip
}
output "cidr_block" {
    value = aws_vpc.vpc.cidr_block
}
output "security_group_id" {
    value = aws_security_group.ec2_sg.id
}
output "ec2_instance_id" {
    value = aws_instance.server.id
}