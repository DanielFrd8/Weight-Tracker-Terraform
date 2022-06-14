resource "azurerm_resource_group" "weight_tracker_rg" {
  name = "WeightTrackerRG"
  location = var.zone_name
}

resource "azurerm_virtual_network" "vnet" {
  name = "VNet"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  location = azurerm_resource_group.weight_tracker_rg.location
  address_space = ["10.0.0.0/16"]
}
