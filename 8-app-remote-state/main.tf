#############################################################################
# VARIABLES
#############################################################################

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "naming_prefix" {
  type    = string
  default = "itma"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "azurerm" {

}

##################################################################################
# RESOURCES
##################################################################################
resource "random_integer" "sa_num" {
  min = 10000
  max = 99999
}


resource "azurerm_resource_group" "setup" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = "${lower(var.naming_prefix)}${random_integer.sa_num.result}"
  resource_group_name      = azurerm_resource_group.setup.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_storage_container" "ct" {
  name                 = "terraform-state"
  storage_account_name = azurerm_storage_account.sa.name

}

data "azurerm_storage_account_sas" "state" {
  connection_string = azurerm_storage_account.sa.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "17520h")

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
  }
}

#############################################################################
# PROVISIONERS
#############################################################################

# Note this should be run on a system with PowerShell installed.  It will not
# run correctly otherwise.

resource "null_resource" "post-config" {

  depends_on = [azurerm_storage_container.ct]

  provisioner "local-exec" {
    command = <<EOT
Add-Content -Value 'storage_account_name = "${azurerm_storage_account.sa.name}"' -Path "backend-config.txt"
Add-Content -Value 'container_name = "terraform-state"' -Path "backend-config.txt"
Add-Content -Value 'key = "terraform.tfstate"' -Path "backend-config.txt"
Add-Content -Value 'sas_token = "${data.azurerm_storage_account_sas.state.sas}"' -Path "backend-config.txt"
EOT

    interpreter = ["PowerShell", "-Command"]
  }
}

##################################################################################
# OUTPUT
##################################################################################

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "resource_group_name" {
  value = azurerm_resource_group.setup.name
}

output "shared_access_signature" {
  value = data.azurerm_storage_account_sas.state.sas
}