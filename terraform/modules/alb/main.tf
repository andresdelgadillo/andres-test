terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}


resource "aws_security_group" "sg_alb" {
  name        = "${var.app_name}-alb-${var.environment}"
  description = "ALB ${var.app_name} security group"
  vpc_id      = var.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "${var.app_name}-alb-${var.environment}"
  }
}

resource "aws_lb" "alb" {
  name               = "${var.app_name}-${var.environment}"
  internal           = "${var.internal}"
  load_balancer_type = "application"

  security_groups = [aws_security_group.sg_alb.id]
  ip_address_type = "ipv4"

  dynamic "subnet_mapping" {
    for_each = var.subnets
    content {
      subnet_id = subnet_mapping.value.id
    }
  }

  tags = {
    Name = "${var.app_name}-${var.environment}"
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name        = "albtg-${var.app_name}"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc.id
  slow_start  = 240

  tags = {
    Name = "albtg-${var.app_name}"
  }
}

resource "aws_lb_listener" "alb_listeners" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
  depends_on = [
    aws_lb_target_group.alb_target_group,
  ]
}
