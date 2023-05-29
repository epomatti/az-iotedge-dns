output "public_ip" {
  value = azurerm_public_ip.dns.ip_address
}

output "private_ip" {
  value = azurerm_network_interface.dns.private_ip_address
}
