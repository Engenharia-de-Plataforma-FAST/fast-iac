# =============================================================================
# LOAD BALANCER MODULE - Application Load Balancer, Target Group, Listeners
# =============================================================================

# =============================================================================
# APPLICATION LOAD BALANCER
# =============================================================================

resource "aws_lb" "main" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
  enable_http2               = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-alb"
    }
  )
}

# =============================================================================
# TARGET GROUP
# =============================================================================

resource "aws_lb_target_group" "web" {
  name     = "${var.name_prefix}-tg-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-tg-web"
    }
  )
}

# =============================================================================
# TARGET GROUP ATTACHMENTS
# =============================================================================

resource "aws_lb_target_group_attachment" "web" {
  count = length(var.web_instance_ids)

  target_group_arn = aws_lb_target_group.web.arn
  target_id        = var.web_instance_ids[count.index]
  port             = 80
}

# =============================================================================
# LISTENER
# =============================================================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-listener-http"
    }
  )
}
