output "alb_sg" {
  value       = aws_security_group.alb_sg.id
  description = "The ALB security group"
}

output "alb_tg_arn" {
  value       = aws_lb_target_group.alb_tg.arn
  description = "The ALB target group ARN"
}

output "alb_arn" {
  value       = aws_lb.aws_alb.arn
  description = "The ALB target group ARN"
}

output "alb_dns_name" {
  value       = aws_lb.aws_alb.dns_name
  description = "The ALB DNS name"
}

# See https://github.com/aws/aws-cdk/issues/17208
# Will use it in depends_on in nlb_tg_attachment
output "alb_listener_port" {
  value       = aws_alb_listener.alb_listener.port
  description = "The ALB listener port"
}