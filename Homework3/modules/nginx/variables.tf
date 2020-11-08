terraform {
  required_version = ">= 0.12.0"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "num_of_web_servers" {
  type        = number
  default     = 2
}

variable "web_servers_intance_type" {
  type        = string
  default     = "t2.micro"
}

variable "intances_private_key_name" {
  type        = string
}

variable "owner_name" {
  type        = string
}

variable "project_name" {
  description = "the project name"
  type        = string
}

variable "public_sub_id" {
  type = list(string)
}

variable "web_server_sg" {
  type = string
}