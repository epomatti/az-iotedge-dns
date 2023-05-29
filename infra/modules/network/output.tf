output "subnet_id" {
  value = azurerm_subnet.default.id
}

output "dns_subnet_id" {
  value = azurerm_subnet.dns.id
}

output "zone_name" {
  value = azurerm_private_dns_zone.default.name
}
