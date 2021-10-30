output "nlb_arn" {
  value       = aws_lb.aws_nlb.arn
  description = "The NLB ARN"
}
output "nlb_tg_arn" {
  value       = aws_lb_target_group.nlb_tg.arn
  description = "The NLB target group ARN"
}