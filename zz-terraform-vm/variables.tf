variable "resource_group_name" {
  type    = string
  default = "terraform-vm"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vnet_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_prefixes" {
  type    = list(string)
  default = ["10.0.0.0/24"]
}

variable "subnet_names" {
  type    = list(string)
  default = ["subnet1"]
}

resource "random_id" "id" {
  byte_length = 4
}

locals {
  storage_account_name = "terraformstate${lower(random_id.id.hex)}"
  vm_public_dns        = "tfvm-${random_id.id.hex}"
}