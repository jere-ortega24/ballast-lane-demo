variable "domain_name" {
  type = string
}

variable "records" {
  type    = any
  default = []
}
