variable "nlb_name" {
  description = "Name for AWS NLB"
  type        = string
  default     = "demo-nlb"
}

variable "nlb_subnets" {
  description = "Subnets in which the private NLB service will be deployed"
  type        = list(any)
}

variable "nlb_tg_name" {
  description = "Name of NLB target group"
  type        = string
  default     = "demo-nlb-target-group"
}

variable "vpc_id" {
  description = "VPC of NLB target group"
  type        = string
}

variable "nlb_port" {
  description = "NLB port"
  type        = number
}

variable "alb_port" {
  description = "ALB port"
  type        = number
}

variable "alb_arn" {
  description = "ALB ARN"
  type        = string
}
