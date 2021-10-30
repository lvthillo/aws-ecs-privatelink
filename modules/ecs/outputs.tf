output "ecs_sg" {
  value       = aws_security_group.ecs_sg.id
  description = "The ECS security group"
}

output "ecs_port" {
  value       = var.ecs_port
  description = "The ECS exposed port"
}