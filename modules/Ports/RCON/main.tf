resource "aws_security_group_rule" "RCON_Web"{
  type              = "ingress"
  from_port         = 4326
  to_port           = 4326
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}

resource "aws_security_group_rule" "RCON_WebSocket"{
  type              = "egress"
  from_port         = 4327
  to_port           = 4327
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}