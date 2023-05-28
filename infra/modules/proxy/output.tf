output "public_ip" {
  value = azurerm_public_ip.proxy.ip_address
}

output "private_ip" {
  value = azurerm_network_interface.proxy.private_ip_address
}
