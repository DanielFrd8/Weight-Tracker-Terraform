output "load_balancer_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}

output "app_vms" {
    value = azurerm_public_ip.app_public_ip.*.ip_address
}

output "app_vms_passwords" {
  sensitive = true
  value = azurerm_linux_virtual_machine.app_vm.*.admin_password
}


