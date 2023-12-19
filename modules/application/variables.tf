variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "The IDs of the public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "The IDs of the private subnets"
  type        = list(string)
}

variable "environment" {
  description = "The environment (e.g., staging, production)"
  type        = string
}

variable "service_names" {
  description = "Names of the services"
  type        = list(string)
}