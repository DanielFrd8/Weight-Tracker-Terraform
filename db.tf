resource "azurerm_subnet" "db_subnet" {
  name = "DBSubnet"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]
  enforce_private_link_endpoint_network_policies = true

  delegation {
    name = "fs"
    service_delegation{
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}


resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "postgresql-pdz.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_vnet_link" {
  name                  = "postgresql-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.weight_tracker_rg.name
}

resource "azurerm_postgresql_flexible_server" "postgres_server" {
  name = "postgres-ser"
  location = azurerm_resource_group.weight_tracker_rg.location
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  version = "13"
  delegated_subnet_id = azurerm_subnet.db_subnet.id
  administrator_login = ""
  administrator_password  = ""
  zone = "1"
  
  storage_mb = 32768
  sku_name = "B_Standard_B1ms"
  private_dns_zone_id = azurerm_private_dns_zone.dns_zone.id

  lifecycle {
      ignore_changes = [
        zone,
        high_availability.0.standby_availability_zone
      ]
  }
}

resource "azurerm_postgresql_flexible_server_database" "postgres_db" {
  name      = "postgres-db"
  server_id = azurerm_postgresql_flexible_server.postgres_server.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_postgresql_flexible_server_configuration" "postgres_off_require_secure_transport" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.postgres_server.id
  value     = "off"
}


# resource "azurerm_network_interface" "db_interface" {
#    name                = "DBIntereface"
#    location            = azurerm_resource_group.weight_tracker_rg.location
#    resource_group_name = azurerm_resource_group.weight_tracker_rg.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.db_subnet.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_linux_virtual_machine" "db_vm" {
#   name                = "DBVM"
#   resource_group_name = azurerm_resource_group.weight_tracker_rg.name
#   location            = azurerm_resource_group.weight_tracker_rg.location
#   size                = "Standard_B1s"
#   network_interface_ids = [
#     azurerm_network_interface.db_interface.id,
#   ]

#   admin_username = ""
#   admin_password = ""
#   disable_password_authentication = false

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#      publisher = "Canonical"
#      offer     = "0001-com-ubuntu-server-focal"
#      sku       = "20_04-lts-gen2"
#      version   = "latest"
#    }
# }