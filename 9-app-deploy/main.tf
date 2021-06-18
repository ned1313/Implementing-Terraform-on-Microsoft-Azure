#############################################################################
# TERRAFORM CONFIG
#############################################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }

  backend "azurerm" {
  }
}

#############################################################################
# VARIABLES
#############################################################################

variable "resource_group_name" {
  type = string
}

variable "naming_prefix" {
  type    = string
  default = "itma"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "network_state" {
  type        = map(string)
  description = "map of network state properties, should include sa, cn, key, and sts"
}

variable "vm_count" {
  type    = number
  default = 2
}

locals {
  prefix = "${terraform.workspace}-${var.naming_prefix}"
}

#############################################################################
# PROVIDERS
#############################################################################

provider "azurerm" {
  features {}
}

#############################################################################
# DATA
#############################################################################

data "azurerm_subscription" "current" {}

data "terraform_remote_state" "networking" {
  backend   = "azurerm"
  workspace = terraform.workspace
  config = {
    storage_account_name = var.network_state["sa"]
    container_name       = var.network_state["cn"]
    key                  = var.network_state["key"]
    sas_token            = var.network_state["sts"]
  }
}

data "azurerm_subnet" "app" {
  name                 = "app"
  virtual_network_name = data.terraform_remote_state.networking.outputs.vnet_name
  resource_group_name  = data.terraform_remote_state.networking.outputs.resource_group_name
}

#############################################################################
# RESOURCES
#############################################################################

resource "azurerm_resource_group" "app" {
  name     = "${local.prefix}-app"
  location = var.location
}

resource "azurerm_availability_set" "app" {
  name                = "${local.prefix}-aset"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  managed             = true

  tags = {
    environment = terraform.workspace
  }
}

resource "azurerm_network_interface" "app" {
  count               = var.vm_count
  name                = "${local.prefix}-${count.index}-nic"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name

  ip_configuration {
    name                          = "config1"
    subnet_id                     = data.azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb" "app" {
  name                = local.prefix
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.app.id
  }
}

resource "azurerm_lb_backend_address_pool" "app" {
  loadbalancer_id = azurerm_lb.app.id
  name            = "${local.prefix}-app"
}

resource "azurerm_network_interface_backend_address_pool_association" "app" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.app[count.index].id
  ip_configuration_name   = "config1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.app.id
}

resource "azurerm_virtual_machine" "main" {
  count                 = var.vm_count
  name                  = "${local.prefix}-${count.index}"
  location              = azurerm_resource_group.app.location
  resource_group_name   = azurerm_resource_group.app.name
  network_interface_ids = [azurerm_network_interface.app[count.index].id]
  availability_set_id   = azurerm_availability_set.app.id
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${local.prefix}${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.naming_prefix}${count.index}vm"
    admin_username = "tfadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = terraform.workspace
  }
}

#############################################################################
# OUTPUTS
#############################################################################

output "lb_private_ip" {
  value = azurerm_lb.app.private_ip_address
}




