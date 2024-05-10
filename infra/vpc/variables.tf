variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(
    object({
      az   = string
      cidr = string
    })
  )
}

variable "private_subnets" {
  type = list(
    object({
      az   = string
      cidr = string
    })
  )
}

variable "domain" {
  type = string
}
