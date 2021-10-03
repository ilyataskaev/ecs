resource "aws_security_group" "public_lb_sg" {
  count = var.use_api_gateway ? 0 : 1
  name  = "${var.service}-public_lb_sg"
  # depends_on = [
  #   aws_security_group.container_sg
  # ]
  description = "Allow incoming from anywhere to HTTPS and HTTP"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = ingress.value
      protocol    = "tcp"
      self        = "false"
      to_port     = ingress.value
    }
  }
  tags   = merge(var.common_tags, var.tags)
  vpc_id = var.vpc
}

resource "aws_security_group" "container_sg" {
  name        = "${var.service}-container_sg"
  description = "Access to the Fargate containers"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    description     = "Ingress"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = var.use_api_gateway ? [] : [aws_security_group.public_lb_sg[0].id]
    self            = var.use_api_gateway ? "true" : "false"
  }

  tags   = merge(var.common_tags, var.tags)
  vpc_id = var.vpc
}
