variable "vpc_name" {
  description = "Name for VPC"
  type        = string
  default     = "vpc"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
}

variable "subnet_1a_public_name" {
  description = "name of public subnet in eu-west-1a"
  type        = string
  default     = "subnet-1a-public"
}

variable "subnet_1a_public_cidr" {
  description = "CIDR for public subnet 1a"
  type        = string
}

variable "subnet_1b_public_name" {
  description = "name of public subnet in eu-west-1b"
  type        = string
  default     = "subnet-1b-public"
}

variable "subnet_1b_public_cidr" {
  description = "CIDR for public subnet 1b"
  type        = string
}

variable "subnet_1a_private_name" {
  description = "name of private subnet in eu-west-1a"
  type        = string
  default     = "subnet-1a-private"
}

variable "subnet_1a_private_cidr" {
  description = "CIDR for private subnet 1a"
  type        = string
}

variable "subnet_1b_private_name" {
  description = "name of private subnet in eu-west-1b"
  type        = string
  default     = "subnet-1b-private"
}

variable "subnet_1b_private_cidr" {
  description = "CIDR for private subnet 1b"
  type        = string
}

variable "igw_name" {
  description = "name of internet gateway"
  type        = string
  default     = "igw"
}

variable "nat_name" {
  description = "name of NAT gateway in eu-west-1a"
  type        = string
  default     = "natgw"
}


