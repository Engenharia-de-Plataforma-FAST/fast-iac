# =============================================================================
# SECURITY MODULE - Security Groups and Rules
# =============================================================================

# =============================================================================
# BASTION SECURITY GROUP
# =============================================================================

resource "aws_security_group" "bastion" {
  count = var.create_bastion_sg ? 1 : 0

  name        = "${var.name_prefix}-sg-bastion"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sg-bastion"
      Role = "Bastion"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  count = var.create_bastion_sg ? 1 : 0

  security_group_id = aws_security_group.bastion[0].id
  description       = "Allow SSH from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sg-rule-bastion-ssh-ingress"
    }
  )
}

resource "aws_vpc_security_group_egress_rule" "bastion_all" {
  count = var.create_bastion_sg ? 1 : 0

  security_group_id = aws_security_group.bastion[0].id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sg-rule-bastion-all-egress"
    }
  )
}

# =============================================================================
# WEB SERVER SECURITY GROUP
# =============================================================================

resource "aws_security_group" "web" {
  count = var.create_web_sg ? 1 : 0

  name        = "${var.name_prefix}-sg-web"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sg-web"
      Role = "WebServer"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "web_http_from_alb" {
  count = var.create_web_sg && var.create_alb_sg ? 1 : 0

  security_group_id            = aws_security_group.web[0].id
  description                  = "Allow HTTP from ALB"
  referenced_security_group_id = aws_security_group.alb[0].id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sg-rule-web-http-from-alb"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "web_ssh_from_bastion" {
  count = var.create_web_sg && var.create_bastion_sg ? 1 : 0

  security_group_id            = aws_security_group.web[0].id
  description                  = "Allow SSH from bastion"
  referenced_security_group_id = aws_security_group.bastion[0].id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sg-rule-web-ssh-from-bastion"
    }
  )
}

resource "aws_vpc_security_group_egress_rule" "web_all" {
  count = var.create_web_sg ? 1 : 0

  security_group_id = aws_security_group.web[0].id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sg-rule-web-all-egress"
    }
  )
}

# =============================================================================
# APPLICATION LOAD BALANCER SECURITY GROUP
# =============================================================================

resource "aws_security_group" "alb" {
  count = var.create_alb_sg ? 1 : 0

  name        = "${var.name_prefix}-sg-alb"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sg-alb"
      Role = "LoadBalancer"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  count = var.create_alb_sg ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  description       = "Allow HTTP from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sg-rule-alb-http-ingress"
    }
  )
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  count = var.create_alb_sg ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sg-rule-alb-all-egress"
    }
  )
}
