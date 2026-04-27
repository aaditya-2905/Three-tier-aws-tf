variable "primary_vpc_id" {
  type = string
}

variable "primary_subnets" {
  type = list(string)
}

variable "primary_vpc_cidr" {
  type = string
}

variable "secondary_vpc_id" {
  type = string
}

variable "secondary_subnets" {
  type = list(string)
}

variable "secondary_vpc_cidr" {
  type = string
}

variable "primary_sg_id" {
  type = string
}

variable "secondary_sg_id" {
  type = string
}
