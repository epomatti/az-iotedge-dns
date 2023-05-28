output "edgegateway_ssh_command" {
  value = "ssh edgegateway@${module.edgegateway.public_ip}"
}

output "proxy_ssh_command" {
  value = "ssh proxy@${module.proxy.public_ip}"
}
