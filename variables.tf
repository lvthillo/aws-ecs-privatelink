variable "ecs_port" {
  description = "Port of ECS task"
  type        = number
  default     = 8080
}

variable "alb_port" {
  description = "Port of ALB"
  type        = number
  default     = 8888
}

variable "nlb_port" {
  description = "Port of NLB"
  type        = number
  default     = 80
}

variable "key" {
  description = "SSH key for EC2"
  type        = string
  default     = "lvthillo"
}

variable "vpc" {
  description = "VPC CIDR"
  default     = "10.100.100.0/24"
}

variable "priv_sub_1a" {
  description = "Private subnet 1a"
  default     = "10.100.100.128/26"
}

variable "priv_sub_1b" {
  description = "Private subnet 1b"
  default     = "10.100.100.192/26"
}

variable "pub_sub_1a" {
  description = "Public subnet 1a"
  default     = "10.100.100.0/26"
}

variable "pub_sub_1b" {
  description = "Public subnet 1b"
  default     = "10.100.100.64/26"
}

variable "vpc_added" {
  description = "VPC CIDR"
  default     = "10.1.1.0/24"
}

variable "priv_sub_1a_added" {
  description = "Private subnet 1a"
  default     = "10.1.1.128/26"
}

variable "priv_sub_1b_added" {
  description = "Private subnet 1b"
  default     = "10.1.1.192/26"
}

variable "pub_sub_1a_added" {
  description = "Public subnet 1a"
  default     = "10.1.1.0/26"
}

variable "pub_sub_1b_added" {
  description = "Public subnet 1b"
  default     = "10.1.1.64/26"
}