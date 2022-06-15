resource "azurerm_subnet" "app_subnet" {
  name = "AppSubnet"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "lb_public_ip" {
  name = "lb-public-ip"
  location = azurerm_resource_group.weight_tracker_rg.location
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_lb" "app_load_balancer" {
  name = "AppLoadBalancer"
  location = azurerm_resource_group.weight_tracker_rg.location
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  sku = "Standard"

  frontend_ip_configuration {
    name = "LBPublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_address_pool" {
  name = "BackendAddressPool"
  loadbalancer_id = azurerm_lb.app_load_balancer.id
}

resource "azurerm_lb_backend_address_pool_address" "lb_address_pool_address" {
  name                    = "LBAddressPool"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool.id
  virtual_network_id      = azurerm_virtual_network.vnet.id
  ip_address              = "10.0.0.1"
}


resource "azurerm_network_interface" "app_interface" {
  count = 3
  name                = "AppIntereface${count.index}"
  location            = azurerm_resource_group.weight_tracker_rg.location
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "app_public_ip" {
  count = 3
  name = "AppPublicIP${count.index}"
  location = azurerm_resource_group.weight_tracker_rg.location
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  allocation_method = "Static"
}

resource "azurerm_linux_virtual_machine" "app_vm" {
  count = 3
  name                = "AppVM${count.index}"
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name
  location            = azurerm_resource_group.weight_tracker_rg.location
  size                = "Standard_B1s"
  network_interface_ids = [element(azurerm_network_interface.app_interface.*.id, count.index)]
  public_ip_address_id = element(azurerm_public_ip.app_public_ip.*.id, count.index)

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
