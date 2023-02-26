
resource "aws_security_group_rule" "SSH"{
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.security_group_id
}

resource "aws_security_group_rule" "Valheim_Ingress_UDP"{
  for_each = toset(var.udp_ports)
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}

resource "aws_security_group_rule" "Valheim_Egress_UDP"{
  for_each = toset(var.udp_ports)
  type              = "egress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}

resource "aws_security_group_rule" "Valheim_Ingress_TCP"{
  for_each = toset(var.tcp_ports)
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}

resource "aws_security_group_rule" "Valheim_Egress_TCP"{
  for_each = toset(var.tcp_ports)
  type              = "egress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}

