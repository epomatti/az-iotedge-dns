output "edgegateway_ssh_command" {
  value = "ssh edgegateway@${module.edgegateway.public_ip}"
}

output "dns_ssh_command" {
  value = "ssh dnsadmin@${module.dns.public_ip}"
}
