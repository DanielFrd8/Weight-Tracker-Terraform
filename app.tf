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

# resource "azurerm_lb_rule" "lb_rule_8080" {
#   loadbalancer_id                = azurerm_lb.app_load_balancer.id
#   name                           = "LBRule8080"
#   protocol                       = "Tcp"
#   frontend_port                  = 8080
#   backend_port                   = 8080
#   frontend_ip_configuration_name = "LBPublicIPAddress"
#   probe_id                       = azurerm_lb_probe.lb_probe.id
#   backend_address_pool_ids = [ azurerm_lb_backend_address_pool.lb_backend_address_pool.id ]
#   disable_outbound_snat          = true
# }

resource "azurerm_lb_probe" "lb_probe" {
  loadbalancer_id = azurerm_lb.app_load_balancer.id
  name            = "ssh-running-probe"
  port            = 22
}

resource "azurerm_lb_backend_address_pool" "lb_backend_address_pool" {
  name = "BackendAddressPool"
  loadbalancer_id = azurerm_lb.app_load_balancer.id
}

# resource "azurerm_lb_backend_address_pool_address" "lb_address_pool_address" {
#   name                    = "LBAddressPool"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool.id
#   virtual_network_id      = azurerm_virtual_network.vnet.id
#   ip_address              = "10.0.0.1"
# }

# resource "azurerm_lb_nat_pool" "lb_nat_pool" {
#   resource_group_name            = azurerm_resource_group.weight_tracker_rg.name
#   loadbalancer_id                = azurerm_lb.app_load_balancer.id
#   name                           = "LoadBalancerApplicationPool"
#   protocol                       = "Tcp"
#   frontend_port_start            = 5000
#   frontend_port_end              = 5002
#   backend_port                   = 8080
#   frontend_ip_configuration_name = "LBPublicIPAddress"
# }

resource "azurerm_lb_outbound_rule" "lb_outbound_rule" {
  loadbalancer_id         = azurerm_lb.app_load_balancer.id
  name                    = "LBOutboundRule"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool.id

  frontend_ip_configuration {
    name = "LBPublicIPAddress"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_backend_pool_association" {
  count = 3
  network_interface_id = azurerm_network_interface.app_interface[count.index].id
  ip_configuration_name = azurerm_network_interface.app_interface[count.index].ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool.id
}

resource "azurerm_network_interface" "app_interface" {
  count = 3
  name                = "AppIntereface${count.index}"
  location            = azurerm_resource_group.weight_tracker_rg.location
  resource_group_name = azurerm_resource_group.weight_tracker_rg.name

  ip_configuration {
    name                          = "internal${count.index}"
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
  sku = "Standard"
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
     offer     = "0001-com-ubuntu-server-focal"
     sku       = "20_04-lts-gen2"
     version   = "latest"
   }
}
