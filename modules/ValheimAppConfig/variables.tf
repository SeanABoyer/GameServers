variable "ec2_security_group_id" {
    type = string
}
variable "cidr_block" {
    type = string
}

variable "udp_ports" {
    type = list(integer)
    default = [2456,2457,2458]
}

variable "tcp_ports" {
    type = list(number)
    default = [2456,2457,2458]
}