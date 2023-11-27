resource "aws_security_group_rule" "RCON_Web"{
  description       = "Allow Inbound Traffic over TCP on Port 3000"
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.ec2_security_group_id
}