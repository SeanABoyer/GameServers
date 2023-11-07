

resource "aws_security_group_rule" "SSH"{
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "CSGO_UDP_27015"{
  type              = "ingress"
  from_port         = 27015
  to_port           = 27015
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "CSGO_UDP_27031_27036"{
  type              = "ingress"
  from_port         = 27031
  to_port           = 27036
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "CSGO_TCP_27015"{
  type              = "ingress"
  from_port         = 27015
  to_port           = 27015
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "CSGO_TCP_27036"{
  type              = "ingress"
  from_port         = 27036
  to_port           = 27036
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}
