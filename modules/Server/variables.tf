variable "game_name" {
    type = string
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

variable "ami_name" {
    type = string
    default = "al2023-ami-2023*"
}

variable "scripts" {
    type = list(map(string))
}