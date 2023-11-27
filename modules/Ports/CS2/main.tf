# resource "aws_security_group_rule" "SSH"{
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = var.ec2_security_group_id
# }

resource "aws_security_group_rule" "CSGO_Outbound"{
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}

resource "aws_security_group_rule" "CSGO_UDP_27015"{
  type              = "ingress"
  from_port         = 27015
  to_port           = 27015
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}

resource "aws_security_group_rule" "CSGO_TCP_27015"{
  type              = "ingress"
  from_port         = 27015
  to_port           = 27015
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}

resource "aws_security_group_rule" "CSGO_UDP_27005"{
  type              = "ingress"
  from_port         = 27005
  to_port           = 27005
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}

resource "aws_security_group_rule" "efs_TCP"{
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  source_security_group_id = var.efs_security_group_id
  security_group_id = var.ec2_security_group_id
}

resource "aws_security_group_rule" "efs_UDP"{
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "udp"
  source_security_group_id = var.efs_security_group_id
  security_group_id = var.ec2_security_group_id
}