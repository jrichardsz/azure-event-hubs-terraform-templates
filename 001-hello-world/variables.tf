variable "owner" {
  type        = string
  default     = "jrichardsz"
  description = "resource owner"
}
variable "location" {
  type = string
  default = "eastus"
}
variable "base_name" {
  type = string
  default = "sandbox"
}
variable "environment" {
  type = string
  default = "dev"
}

variable "principal_id" {
  type = string
  default = ""
}

variable "storage_account_name" {
  type = string
  default = "acmestorage"
}

variable "tags" {
  type = map(string)
  default = {
    owner  = "jrichardsz"
  }
}