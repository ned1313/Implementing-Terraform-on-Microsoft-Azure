#############################################################################
# TERRAFORM CONFIG
#############################################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

#############################################################################
# VARIABLES
#############################################################################

variable "sec_resource_group_name" {
  type    = string
  default = "security"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vnet_cidr_range" {
  type    = string
  default = "10.1.0.0/16"
}

variable "sec_subnet_prefixes" {
  type    = list(string)
  default = ["10.1.0.0/24", "10.1.1.0/24"]
}

variable "sec_subnet_names" {
  type    = list(string)
  default = ["siem", "inspect"]
}

#############################################################################
# DATA
#############################################################################

data "azurerm_subscription" "current" {}

#############################################################################
# PROVIDERS
#############################################################################

provider "azurerm" {
  features {}
}

#############################################################################
# RESOURCES
#############################################################################

## NETWORKING ##

resource "azurerm_resource_group" "vnet_sec" {
  name     = var.sec_resource_group_name
  location = var.location
}

module "vnet-sec" {
  source              = "Azure/vnet/azurerm"
  version             = "~> 2.0"
  resource_group_name = azurerm_resource_group.vnet_sec.name
  vnet_name           = var.sec_resource_group_name
  address_space       = [var.vnet_cidr_range]
  subnet_prefixes     = var.sec_subnet_prefixes
  subnet_names        = var.sec_subnet_names
  nsg_ids             = {}

  tags = {
    environment = "security"
    costcenter  = "security"

  }

  depends_on = [azurerm_resource_group.vnet_sec]
}

## AZURE AD SP ##

resource "random_password" "vnet_peering" {
  length  = 16
  special = true
}

resource "azuread_application" "vnet_peering" {
  display_name = "vnet-peer"
}

resource "azuread_service_principal" "vnet_peering" {
  application_id = azuread_application.vnet_peering.application_id
}

resource "azuread_service_principal_password" "vnet_peering" {
  service_principal_id = azuread_service_principal.vnet_peering.id
  value                = random_password.vnet_peering.result
  end_date_relative    = "17520h"
}

resource "azurerm_role_definition" "vnet-peering" {
  name  = "allow-vnet-peering"
  scope = data.azurerm_subscription.current.id

  permissions {
    actions     = ["Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write", "Microsoft.Network/virtualNetworks/peer/action", "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read", "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id,
  ]
}

resource "azurerm_role_assignment" "vnet" {
  scope              = module.vnet-sec.vnet_id
  role_definition_id = azurerm_role_definition.vnet-peering.role_definition_resource_id
  principal_id       = azuread_service_principal.vnet_peering.id
}

#############################################################################
# FILE OUTPUT
#############################################################################

resource "local_file" "linux" {
  filename = "${path.module}/next-step.txt"
  content  = <<EOF
export TF_VAR_sec_vnet_id=${module.vnet-sec.vnet_id}

export TF_VAR_sec_vnet_name=${module.vnet-sec.vnet_name}
export TF_VAR_sec_sub_id=${data.azurerm_subscription.current.subscription_id}
export TF_VAR_sec_client_id=${azuread_service_principal.vnet_peering.application_id}
export TF_VAR_sec_principal_id=${azuread_service_principal.vnet_peering.id}
export TF_VAR_sec_client_secret='${random_password.vnet_peering.result}'
export TF_VAR_sec_resource_group=${var.sec_resource_group_name}
export TF_VAR_sec_tenant_id=${data.azurerm_subscription.current.tenant_id}

  EOF
}

resource "local_file" "windows" {
  filename = "${path.module}/windows-next-step.txt"
  content  = <<EOF
$env:TF_VAR_sec_vnet_id="${module.vnet-sec.vnet_id}"

$env:TF_VAR_sec_vnet_name="${module.vnet-sec.vnet_name}"
$env:TF_VAR_sec_sub_id="${data.azurerm_subscription.current.subscription_id}"
$env:TF_VAR_sec_client_id="${azuread_service_principal.vnet_peering.application_id}"
$env:TF_VAR_sec_principal_id="${azuread_service_principal.vnet_peering.id}"
$env:TF_VAR_sec_client_secret="${random_password.vnet_peering.result}"
$env:TF_VAR_sec_resource_group="${var.sec_resource_group_name}"
$env:TF_VAR_sec_tenant_id="${data.azurerm_subscription.current.tenant_id}"

  EOF
}

#############################################################################
# OUTPUTS
#############################################################################

output "vnet_id" {
  value = module.vnet-sec.vnet_id
}

output "vnet_name" {
  value = module.vnet-sec.vnet_name
}

output "service_principal_client_id" {
  value = azuread_service_principal.vnet_peering.id
}

output "service_principal_client_secret" {
  value = nonsensitive(random_password.vnet_peering.result)
}

output "resource_group_name" {
  value = var.sec_resource_group_name
}