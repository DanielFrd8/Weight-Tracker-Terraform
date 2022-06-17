resource "azurerm_network_security_group" "app_nsg" {
  name = "AppNsg"
  location = azurerm_resource_group.weight_tracker_rg.location
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
}

resource "azurerm_subnet_network_security_group_association" "app-subnet-nsg-assosiation" {
  subnet_id = azurerm_subnet.app_subnet.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

resource "azurerm_network_security_rule" "app_ssh" {
  name = "SSH"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "VirtualNetwork"
  destination_port_range = "22"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}

resource "azurerm_network_security_rule" "app_8080" {
  name = "Port_8080"
  priority = 110
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "AzureLoadBalancer"
  destination_port_range = "8080"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}

resource "azurerm_network_security_rule" "app_deny_all" {
  name = "DenyAll"
  priority = 300
  direction = "Inbound"
  access = "Deny"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_port_range = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}