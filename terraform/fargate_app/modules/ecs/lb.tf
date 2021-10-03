resource "aws_lb" "public_lb" {
  count           = var.use_api_gateway ? 0 : 1
  idle_timeout    = "30"
  name            = "${var.service}-${terraform.workspace}"
  security_groups = [aws_security_group.public_lb_sg[0].id]
  subnets         = var.public_subnets
  tags            = merge(var.common_tags, var.tags)
}

resource "aws_lb_listener" "public_lb_listener_http" {
  count = var.use_api_gateway ? 0 : 1
  default_action {
    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
    type = "redirect"
  }

  load_balancer_arn = aws_lb.public_lb[0].arn
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_lb_listener" "public_lb_listener_https" {
  count           = var.use_api_gateway ? 0 : var.use_https_listener ? 1 : 0

  default_action {
    target_group_arn = aws_lb_target_group.service_target_group[0].arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.public_lb[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
}
resource "aws_lb_target_group" "service_target_group" {
  count = var.use_api_gateway ? 0 : 1
  health_check {
    healthy_threshold   = "2"
    interval            = "6"
    matcher             = "200,301,302"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    unhealthy_threshold = "2"
  }

  name       = "${var.service}-${terraform.workspace}"
  port       = var.container_port
  protocol   = "HTTP"
  slow_start = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }

  tags = merge(var.common_tags, var.tags)

  target_type = "ip"
  vpc_id      = var.vpc
}
