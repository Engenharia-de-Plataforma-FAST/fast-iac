# Security Group for Web Server
resource "aws_security_group" "web_sg" {
  name_prefix = "${local.name_prefix}-sg-web-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for web server"

  tags = {
    Name = "${local.name_prefix}-sg-web"
    Type = "WebServer"
  }
}

# SSH Access Rule
resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_cidrs
  security_group_id = aws_security_group.web_sg.id
  description       = "Allow SSH access from specified CIDR blocks"
}

# HTTP Access Rule
resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
  description       = "Allow HTTP access from anywhere"
}

# ICMP (Ping) Rule
resource "aws_security_group_rule" "icmp_ingress" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
  description       = "Allow ICMP ping from anywhere"
}

# Egress Rule - Allow all outbound traffic
resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
  description       = "Allow all outbound traffic"
}