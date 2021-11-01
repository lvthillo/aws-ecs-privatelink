resource "aws_lb" "aws_alb" {
  name               = var.alb_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.alb_subnets
  #checkov:skip=CKV_AWS_91:For this demo I don't need access logging enabled
  #checkov:skip=CKV_AWS_150:For this demo I don't need ELB deletion protection
  #checkov:skip=CKV_AWS_152:For this demo I don't need cross zone load balancing enabled
  enable_deletion_protection = false
  drop_invalid_header_fields = true
}

resource "aws_security_group" "alb_sg" {
  name        = var.alb_sg_name
  description = var.alb_sg_description
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  description       = "Traffic from NLB to ALB"
  from_port         = var.alb_port
  to_port           = var.alb_port
  protocol          = "tcp"
  security_group_id = aws_security_group.alb_sg.id
  //NLB has no security group so we will whitelist the VPC CIDR cidr_blocks = var.vpc_cidr
  cidr_blocks = [var.vpc_cidr]
}

resource "aws_security_group_rule" "egress" {
  type                     = "egress"
  description              = "Traffic from ALB to ECS"
  from_port                = var.ecs_port
  to_port                  = var.ecs_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_sg.id
  source_security_group_id = var.ecs_sg
}

resource "aws_lb_target_group" "alb_tg" {
  name        = var.alb_tg_name
  port        = var.ecs_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.aws_alb.arn
  port              = var.alb_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    type             = "forward"
  }
}