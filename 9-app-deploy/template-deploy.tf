#############################################################################
# DATA
#############################################################################

data "azurerm_subnet" "appservice" {
  name                 = "appservice"
  virtual_network_name = data.terraform_remote_state.networking.outputs.vnet_name
  resource_group_name  = data.terraform_remote_state.networking.outputs.resource_group_name
}

#############################################################################
# RESOURCES
#############################################################################

resource "azurerm_resource_group" "webapp" {
  name     = "${local.prefix}-webapp"
  location = var.location
}

resource "azurerm_template_deployment" "webapp" {
  name                = "webappdeployment"
  resource_group_name = azurerm_resource_group.webapp.name

  template_body = file("azuredeploy.json")

  parameters = {
    "webAppName" = "${local.prefix}-web"
    "vnetName"   = data.terraform_remote_state.networking.outputs.vnet_name
    "subnetRef"  = data.azurerm_subnet.appservice.id
  }

  deployment_mode = "Incremental"
}