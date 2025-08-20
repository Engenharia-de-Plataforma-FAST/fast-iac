# Security Group for Bastion Host (SSH only)
resource "aws_security_group" "bastion_sg" {
  name_prefix = "${local.name_prefix}-sg-bastion-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for bastion host"

  tags = {
    Name = "${local.name_prefix}-sg-bastion"
    Type = "BastionHost"
  }
}

# Security Group for Web Servers (HTTP + SSH from bastion)
resource "aws_security_group" "web_sg" {
  name_prefix = "${local.name_prefix}-sg-web-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for web servers in private subnets"

  tags = {
    Name = "${local.name_prefix}-sg-web"
    Type = "WebServers"
  }
}

# Security Group for ALB (HTTP from internet)
resource "aws_security_group" "alb_sg" {
  name_prefix = "${local.name_prefix}-sg-alb-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for Application Load Balancer"

  tags = {
    Name = "${local.name_prefix}-sg-alb"
    Type = "LoadBalancer"
  }
}

# =============================================================================
# BASTION HOST SECURITY GROUP RULES
# =============================================================================

# SSH access to bastion from specified CIDRs
resource "aws_security_group_rule" "bastion_ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_cidrs
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Allow SSH access to bastion from specified CIDR blocks"
}

# Allow all outbound traffic from bastion
resource "aws_security_group_rule" "bastion_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Allow all outbound traffic from bastion"
}

# =============================================================================
# WEB SERVERS SECURITY GROUP RULES  
# =============================================================================

# SSH access to web servers only from bastion
resource "aws_security_group_rule" "web_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_security_group.web_sg.id
  description              = "Allow SSH access from bastion host only"
}

# HTTP access to web servers only from ALB
resource "aws_security_group_rule" "web_http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.web_sg.id
  description              = "Allow HTTP access from ALB only"
}

# Allow all outbound traffic from web servers
resource "aws_security_group_rule" "web_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
  description       = "Allow all outbound traffic from web servers"
}

# =============================================================================
# ALB SECURITY GROUP RULES
# =============================================================================

# HTTP access to ALB from internet
resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP access from internet"
}

# Allow outbound traffic to web servers
resource "aws_security_group_rule" "alb_to_web_egress" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web_sg.id
  security_group_id        = aws_security_group.alb_sg.id
  description              = "Allow outbound HTTP to web servers"
}

