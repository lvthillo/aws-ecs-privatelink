variable "ecs_cluster_name" {
  description = "Name for ECS cluster"
  type        = string
  default     = "ecs-cluster"
}

variable "ecs_service_name" {
  description = "Name for ECS service"
  type        = string
  default     = "ecs-service"
}

variable "ecs_service_count" {
  description = "Count of ECS containers"
  type        = number
  default     = 2
}

variable "ecs_subnets" {
  description = "Subnets in which the ECS service will be deployed"
  type        = list(any)
}

variable "ecs_container_name" {
  description = "Name of ECS container"
  type        = string
}

variable "ecs_port" {
  description = "ECS port"
  type        = number
}

variable "alb_target_group_arn" {
  description = "ARN of ALB target group"
  type        = string
}

variable "ecs_task_def_name" {
  description = "Name for task definition"
  type        = string
}

variable "ecs_task_cpu" {
  description = "Amount of CPU reserved for ECS task"
  type        = number
  default     = 256
}

variable "ecs_task_memory" {
  description = "Amount of memory reserved for ECS task"
  type        = number
  default     = 512
}

variable "ecs_docker_image" {
  description = "Name of docker image"
  type        = string
}

variable "ecs_sg_name" {
  description = "ECS security group name"
  type        = string
  default     = "ecs-sgrp"
}

variable "ecs_sg_description" {
  description = "ECS security group description"
  type        = string
  default     = "ECS security group"
}

variable "vpc_id" {
  description = "VPC of ECS sgrp"
  type        = string
}

variable "alb_sg" {
  description = "Application LB security group"
  type        = string
}



