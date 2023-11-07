terraform {
    required_version = ">=1.1.3"
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "4.40.0"
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

data "aws_region" "current" {}

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

resource "time_sleep" "wait_15_seconds" {
  depends_on = [aws_iam_role.serverRole]
  create_duration = "15s"
}

resource "aws_iam_instance_profile" "serverInstanceProfile" {
  name = local.gameInstanceName
  role = aws_iam_role.serverRole.name
}
#END# IAM Role

#START# Instance

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

data "aws_ami" "amazon_linux_latest" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = [var.ami_name]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ec2_instance_type" "this" {
  instance_type = var.instance_type
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.amazon_linux_latest.id
  instance_type = data.aws_ec2_instance_type.this.instance_type
  iam_instance_profile = aws_iam_instance_profile.serverInstanceProfile.name
  private_ip = var.private_ip

  subnet_id = aws_subnet.subnet.id
  key_name = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = "${data.template_cloudinit_config.user_data.rendered}"
  user_data_replace_on_change = true

}

resource "aws_security_group" "ec2_sg" {
  name = "${local.gameInstanceName}-ec2-sg"
  vpc_id = aws_vpc.vpc.id
}
#END# Instance

#START# CloudWatch
resource "aws_cloudwatch_metric_alarm" "cw_connections" {
  alarm_name                = "StopInstance"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "4"
  metric_name               = "ConnectionsOn25565"
  namespace                 = "CustomEC2"
  period                    = "900"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This alarm will trigger anytime the custom metric is below 1 for more than 1 hour straight."
  actions_enabled           = true
  alarm_actions             = [
    "arn:aws:automate:${data.aws_region.current.name}:ec2:stop"
  ]
  dimensions = {
    InstanceId = "${aws_instance.server.id}"
  }
}
#END# CloudWatch

#START# EFS
resource "aws_efs_file_system" "efs" {}
resource "aws_efs_mount_target" "efs_mount_target" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_subnet.subnet.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id
  policy = data.aws_iam_policy_document.efs_mounting_policy.json
}

data "aws_iam_policy_document" "efs_mounting_policy" {
  #https://docs.aws.amazon.com/efs/latest/ug/iam-access-control-nfs-efs.html
  statement{ 
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess"
    ]
    principals {
      identifiers = [aws_iam_role.serverRole.arn]
      type = "AWS"
    }
    resources = [
      aws_efs_file_system.efs.arn
    ]
  }
  depends_on = [
    time_sleep.wait_15_seconds
  ]
}

resource "aws_security_group" "efs_sg" {
  name = "${local.gameInstanceName}-efs-sg"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "efs_inbound_111_tcp"{
  type              = "ingress"
  from_port         = 111
  to_port           = 111
  protocol          = "TCP"
  source_security_group_id = aws_security_group.ec2_sg.id
  security_group_id = aws_security_group.efs_sg.id
}
resource "aws_security_group_rule" "efs_inbound_111_udp"{
  type              = "ingress"
  from_port         = 111
  to_port           = 111
  protocol          = "UDP"
  source_security_group_id = aws_security_group.ec2_sg.id
  security_group_id = aws_security_group.efs_sg.id
}
resource "aws_security_group_rule" "efs_inbound_2049_tcp"{
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "TCP"
  source_security_group_id = aws_security_group.ec2_sg.id
  security_group_id = aws_security_group.efs_sg.id
}
resource "aws_security_group_rule" "efs_inbound_2049_udp"{
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "UDP"
  source_security_group_id = aws_security_group.ec2_sg.id
  security_group_id = aws_security_group.efs_sg.id
}
#END# EFS

#START# Networking
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
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