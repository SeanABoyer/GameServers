terraform {
    required_version = ">=1.1.3"
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 3.0"
      }
    }
}
provider "aws" {
    default_tags {
        tags = {
            Name = local.gameInstanceName
            Game = var.game_name
        }
    }
}

locals  {
    gameInstanceName = "${var.game_name}-${random_uuid.server_name.result}"
}
resource "random_uuid" "server_name" {
}

#START# IAM Role
data "aws_iam_policy" "AmazonSSMFullAccess"{
  name = "AmazonSSMFullAccess"
}
resource "aws_iam_role" "serverRole" {
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
resource "aws_iam_instance_profile" "serverInstanceProfile" {
  name = local.gameInstanceName
  role = aws_iam_role.serverRole.name
}
#END# IAM Role

#START# Instance
data "aws_ami" "debian" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-11-*"]
  }
  owners = ["136693071363"] #Debian Bullseye [https://wiki.debian.org/Cloud/AmazonEC2Image/Bullseye]
}
resource "aws_key_pair" "ssh_key" {
  key_name = "ssh_${local.gameInstanceName}"
  public_key = var.public_ssh_key
}

data "template_cloudinit_config" "user_data" {
  gzip = true
  base64_encode = true
  part {
    filename = "SSMAgentDebian.sh"
    content_type = "text/x-shellscript"
    content = "${file("${path.module}/deploySSMAgent.sh")}"
  }
  part {
    filename = "applicationInstallScript.sh"
    content_type = "text/x-shellscript"
    content = var.application_install_script
  }
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.debian.id
  availability_zone = var.availability_zone
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.serverInstanceProfile.name
  private_ip = var.private_ip

  subnet_id = aws_subnet.subnet.id
  key_name = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data= "${data.template_cloudinit_config.user_data.rendered}"
  root_block_device {
    volume_size = var.root_block_size
  }
}

resource "aws_security_group" "ec2_sg" {
  name = "${local.gameInstanceName}-ec2-sg"
  vpc_id = aws_vpc.vpc.id
}
#END# Instance

#START# EFS
resource "aws_efs_file_system" "efs" {}
resource "aws_efs_mount_target" "efs_mount_target" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_subnet.subnet.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_security_group" "efs_sg" {
  name = "${local.gameInstanceName}-efs-sg"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "efs_inbound_2049"{
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "-1"
  source_security_group_id = aws_security_group.ec2_sg.id
  security_group_id = aws_security_group.efs_sg.id
}
resource "aws_security_group_rule" "efs_outbound_2049"{
  type              = "egress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "-1"
  source_security_group_id = aws_security_group.ec2_sg.id
  security_group_id = aws_security_group.efs_sg.id
}
#END# EFS

#START# Networking
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
}
resource "aws_internet_gateway" "gw" {
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
  instance = aws_instance.server.id
  vpc = true
  associate_with_private_ip = aws_instance.server.private_ip
  depends_on                = [aws_internet_gateway.gw]
}
#END# Networking