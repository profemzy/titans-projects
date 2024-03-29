variable "vpc_cidr" {
  default = "10.20.0.0/16"
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnets_cidr" {
  type    = list(string)
  default = ["10.20.6.0/24", "10.20.7.0/24"]
}

variable "azs" {
  type    = list(string)
  default = ["us-west-1a", "us-west-1b"]
}

variable "environment" {
  type    = string
  default = "dev"
}
