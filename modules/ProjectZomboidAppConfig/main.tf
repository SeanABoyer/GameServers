

resource "aws_security_group_rule" "SSH"{
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "ProjectZomboid_UDP_8766"{
  type              = "ingress"
  from_port         = 8766
  to_port           = 8766
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "ProjectZomboid_UDP_16261"{
  type              = "ingress"
  from_port         = 16261
  to_port           = 16261
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

