# Application Load Balancer
resource "aws_lb" "web_alb" {
  name               = "${local.name_prefix}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  enable_deletion_protection = false

  tags = {
    Name = "${local.name_prefix}-web-alb"
    Type = "LoadBalancer"
  }
}

# Target Group for web servers
resource "aws_lb_target_group" "web_servers" {
  name     = "${local.name_prefix}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name = "${local.name_prefix}-web-target-group"
  }
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "web_server_1" {
  target_group_arn = aws_lb_target_group.web_servers.arn
  target_id        = aws_instance.web_server_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_server_2" {
  target_group_arn = aws_lb_target_group.web_servers.arn
  target_id        = aws_instance.web_server_2.id
  port             = 80
}

# ALB Listener
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_servers.arn
  }

  tags = {
    Name = "${local.name_prefix}-web-listener"
  }
}