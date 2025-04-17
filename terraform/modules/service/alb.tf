resource "aws_lb" "dev" {
  name               = "${var.app_name}-${var.branch_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnets

  tags = {
    Name = "${var.app_name}-${var.branch_name}-alb"
  }
}

resource "aws_lb_target_group" "dev" {
  name     = "${var.app_name}-${var.branch_name}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "ip"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.app_name}-${var.branch_name}-tg"
  }
}

resource "aws_lb_listener" "dev" {
  load_balancer_arn = aws_lb.dev.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev.arn
  }
}