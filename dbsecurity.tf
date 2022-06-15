resource "azurerm_network_security_group" "db_nsg" {
  name = "DBNsg"
  location = azurerm_resource_group.weight_tracker_rg.location
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
}

resource "azurerm_subnet_network_security_group_association" "db-subnet-nsg-assosiation" {
  subnet_id = azurerm_subnet.db_subnet.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}

resource "azurerm_network_security_rule" "db_ssh" {
  name = "SSH"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "10.0.0.0/24"
  destination_port_range = "22"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

resource "azurerm_network_security_rule" "db_5432" {
  name = "Port_5432"
  priority = 110
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "10.0.0.0/24"
  destination_port_range = "5432"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

resource "azurerm_network_security_rule" "db_deny_all" {
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
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

