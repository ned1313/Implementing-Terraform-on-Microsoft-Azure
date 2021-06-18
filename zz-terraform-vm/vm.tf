# Password for Terraform VM
resource "random_password" "terraform_vm" {
  length  = 16
  special = true
}

# Resource group for Terraform VM
resource "azurerm_resource_group" "vnet_main" {
  name     = var.resource_group_name
  location = var.location
}

# Network for Terraform VM
module "vnet-main" {
  source              = "Azure/vnet/azurerm"
  version             = "~> 2.0"
  resource_group_name = azurerm_resource_group.vnet_main.name
  vnet_name           = var.resource_group_name
  address_space       = [var.vnet_cidr_range]
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  nsg_ids             = {}

  tags = {
    environment = "terraform"
    costcenter  = "it"

  }

  depends_on = [azurerm_resource_group.vnet_main]
}

# Storage account for Terraform VM
resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.vnet_main.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_storage_container" "ct" {
  name                 = "terraform-state"
  storage_account_name = azurerm_storage_account.sa.name

}

# Compute deployment for Terraform VM using Ubuntu
module "terraform-vm" {
  source                        = "Azure/compute/azurerm"
  version                       = "~> 3.0"
  resource_group_name           = azurerm_resource_group.vnet_main.name
  vm_os_simple                  = "UbuntuServer"
  public_ip_dns                 = [local.vm_public_dns]
  vnet_subnet_id                = module.vnet-main.vnet_subnets[0]
  remote_port                   = "22"
  admin_password                = random_password.terraform_vm.result
  enable_ssh_key                = false
  delete_os_disk_on_termination = true

  custom_data = base64encode(templatefile("${path.module}/terraform-vm.tmpl", {
    storage_account_name = azurerm_storage_account.sa.name
    access_key           = azurerm_storage_account.sa.primary_access_key
  }))


  depends_on = [azurerm_resource_group.vnet_main]
}

output "public_ip_address" {
  value = module.terraform-vm.public_ip_address
}

output "password" {
  value = nonsensitive(random_password.terraform_vm.result)
}