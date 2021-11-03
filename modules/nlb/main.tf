resource "aws_lb" "aws_nlb" {
  name               = var.nlb_name
  internal           = true
  load_balancer_type = "network"
  subnets            = var.nlb_subnets
  #checkov:skip=CKV_AWS_91:For this demo I don't need access logging enabled
  #checkov:skip=CKV_AWS_150:For this demo I don't need ELB deletion protection
  #checkov:skip=CKV_AWS_152:For this demo I don't need cross zone load balancing enabled
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "nlb_tg" {
  name        = var.nlb_tg_name
  port        = var.alb_listener_port
  protocol    = "TCP"
  target_type = "alb"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group_attachment" "nlb_tg_attachment" {
  target_group_arn = aws_lb_target_group.nlb_tg.arn
  target_id        = var.alb_arn
  port             = var.alb_listener_port
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.aws_nlb.arn
  port              = var.nlb_port
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.nlb_tg.arn
    type             = "forward"
  }
}

