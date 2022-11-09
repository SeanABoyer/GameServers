variable "game_name" {
    type = string
}

variable "availability_zone" {
    type = string
    default = "us-west-2a"
}
variable "instance_type" {
    type = string
    default = "t2.medium"
}
variable "public_ssh_key" {
    type = string
}
variable "ssh_username" {
    type = string
    default = "admin"
}
variable "root_block_size"{
    type = number
    default = 8
}
variable "private_ip"{
    type = string
    default = "10.0.1.100"
}
variable "subnet_cidr_block"{
    type = string
    default = "10.0.1.0/24"
}
variable "vpc_cidr_block"{
    type = string
    default = "10.0.0.0/16"
}
variable "application_install_script" {
    type = string
}