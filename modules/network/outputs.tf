output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "private_subnets" {
  value       = [aws_subnet.subnet_1a_private.id, aws_subnet.subnet_1b_private.id]
  description = "List of private subnets"
}

output "public_subnets" {
  value       = [aws_subnet.subnet_1a_public.id, aws_subnet.subnet_1b_public.id]
  description = "List of public subnets"
}

output "default_vpc_sg" {
  value       = aws_vpc.vpc.default_security_group_id
  description = "Default security group of our VPC"
}