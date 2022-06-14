resource "azurerm_subnet" "app_subnet" {
  name = "AppSubnet"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.0.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_public_ip" "lb_public_ip" {
  name = lb-public-ip
  location = azurerm_resource_group.weight_tracker_rg.location
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  allocation_method = "static"
}

resource "azurerm_lb" "app_load_balancer" {
  name = "AppLoadBalancer"
  location = azurerm_resource_group.weight_tracker_rg.location
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name

  frontend_ip_configuration {
    name = "LBPublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}
