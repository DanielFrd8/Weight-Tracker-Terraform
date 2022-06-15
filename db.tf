resource "azurerm_subnet" "db_subnet" {
  name = "DBSubnet"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_network_interface" "db_interface" {
   name                = "DBIntereface"
   location            = azurerm_resource_group.weight_tracker_rg.location
   resource_group_name = azurerm_resource_group.weight_tracker_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.db_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "db_vm" {
  name                = "DBVM"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  location            = azurerm_resource_group.weight_tracker_rg.location
  size                = "Standard_B1s"
  network_interface_ids = [
    azurerm_network_interface.db_interface.id,
  ]

  admin_username = ""
  admin_password = ""
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}