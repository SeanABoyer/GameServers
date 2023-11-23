

resource "aws_security_group_rule" "SSH"{
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}

resource "aws_security_group_rule" "MineCraft_TCP"{
  type              = "ingress"
  from_port         = 25565
  to_port           = 25565
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}

resource "aws_security_group_rule" "MineCraft_UDP"{
  type              = "ingress"
  from_port         = 25565
  to_port           = 25565
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}

resource "aws_security_group_rule" "MineCraft_Outbound"{
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
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