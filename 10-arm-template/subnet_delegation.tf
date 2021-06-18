resource "azurerm_subnet" "app_service" {
  name                 = "appservice"
  resource_group_name  = azurerm_resource_group.vnet_main.name
  virtual_network_name = module.vnet-main.vnet_name
  address_prefix       = cidrsubnet(var.vnet_cidr_range[terraform.workspace], 8, length(var.subnet_names))

  delegation {
    name = "appservicedelegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}