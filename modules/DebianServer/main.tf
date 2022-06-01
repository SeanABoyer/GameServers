terraform {
    required_version = ">=1.1.3"
}
locals  {
    gameInstanceName = "${var.game_name}-${random_uuid.server_name.result}"
}
resource "random_uuid" "server_name" {
}
provider "aws" {
    region = var.region
    default_tags {
        tags = {
            Name = local.gameInstanceName
            Game = var.game_name
        }
    }
}

#START# IAM Role
data "aws_iam_policy" "AmazonSSMFullAccess"{
  name = "AmazonSSMFullAccess"
}
resource "aws_iam_role" "mcServerRole" {
  name = local.gameInstanceName
  managed_policy_arns =[
    data.aws_iam_policy.AmazonSSMFullAccess.arn
    ]
    assume_role_policy = jsonencode(
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Action": "sts:AssumeRole",
            "Principal": {
              "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
          }
        ]
      }
    )
}
resource "aws_iam_instance_profile" "mcServerInstanceProfile" {
  name = local.gameInstanceName
  role = aws_iam_role.mcServerRole.name
}
#END# IAM Role

#START# Instance
data "aws_ami" "debian" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-11-*"]
  }
  owners = ["136693071363"] #Debian Buster [https://wiki.debian.org/Cloud/AmazonEC2Image/Buster]
}
resource "aws_key_pair" "ssh_key" {
  key_name = "ssh_${local.gameInstanceName}"
  public_key = var.public_ssh_key
}
resource "aws_instance" "server" {
  ami           = data.aws_ami.debian.id
  availability_zone = var.availability_zone
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.mcServerInstanceProfile.name
  private_ip = var.private_ip

  subnet_id = aws_subnet.subnet.id
  key_name = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.security_group.id]

  user_data= "${file("${path.module}/deploySSMAgent.sh")}"
  root_block_device {
    volume_size = var.root_block_size
  }
}
#END# Instance

#START# Networking
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route" "route_ign_to_vpc" {
  route_table_id = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_eip" "eip" {
  instance = aws_instance.mc_server.id
  vpc = true
  associate_with_private_ip = aws_instance.server.private_ip
  depends_on                = [aws_internet_gateway.gw]
}
#END# Networking