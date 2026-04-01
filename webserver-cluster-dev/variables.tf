variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "day4-cluster"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "server_port" {
  type    = number
  default = 8080
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 5
}
