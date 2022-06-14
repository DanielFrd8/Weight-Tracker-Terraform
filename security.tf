resource "azurerm_network_security_group" "app_nsg" {
  name = "AppNsg"
  location = azurerm_resource_group.weight_tracker_rg.location
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
}

resource "azurerm_subnet_network_security_group_association" "app-subnet-nsg-assosiation" {
  subnet_id = azurerm_subnet.app-subnet.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

resource "azurerm_network_security_rule" "SSH" {
  name = "SSH"
  priority = 100
  direction = "inbound"
  access = "allow"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "10.100.102.37"
  destination_port_range = "22"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}

resource "azurerm_network_security_rule" "Port_8080" {
  name = "Port_8080"
  priority = 110
  direction = "inbound"
  access = "allow"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "AzureLoadBalancer"
  destination_port_range = "8080"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}

resource "azurerm_network_security_rule" "Deny_all" {
  name = "Port_8080"
  priority = 110
  direction = "inbound"
  access = "allow"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "AzureLoadBalancer"
  destination_port_range = "8080"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}