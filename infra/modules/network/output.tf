output "subnet_id" {
  value = azurerm_subnet.default.id
}

output "proxy_subnet_id" {
  value = azurerm_subnet.proxy.id
}

output "zone_name" {
  value = azurerm_private_dns_zone.default.name
}
