variable "alb_name" {
  description = "Name for AWS ALB"
  type        = string
  default     = "demo-alb"
}

variable "alb_subnets" {
  description = "Subnets in which the private ALB service will be deployed"
  type        = list(string)
}

variable "alb_sg_name" {
  description = "Name for AWS ALB security group"
  type        = string
  default     = "alb-sg"
}

variable "alb_sg_description" {
  description = "Description for AWS ALB security group"
  type        = string
  default     = "AWS ALB security group"
}

variable "vpc_id" {
  description = "VPC of ALB security group and target group"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "default_vpc_sg" {
  description = "Default VPC security gruop"
  type        = string
}

variable "alb_port" {
  description = "ALB port"
  type        = number
}

variable "ecs_port" {
  description = "ECS port"
  type        = number
}

variable "ecs_sg" {
  description = "Security group of ECS"
  type        = string
}

variable "alb_tg_name" {
  description = "Name of ALB target group"
  type        = string
  default     = "demo-alb-target-group"
}