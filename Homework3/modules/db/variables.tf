# DB VARIABLES

variable "project_name" {
  description = "the project name"
  type        = string
}

variable "num_of_db_servers" {
  type        = number
  default     = 2
}

variable "db_servers_intance_type" {
  type        = string
  default     = "t2.micro"
}


variable "intances_private_key_name" {
  type        = string
}

variable "owner_name" {
  type        = string
}

variable "private_subnet_id" {
  type = list(string)
}

variable "db_server_sg" {
  type = string
}