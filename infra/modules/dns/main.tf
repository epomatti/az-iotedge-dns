resource "azurerm_public_ip" "dns" {
  name                = "pip-${var.workload}-dns"
  resource_group_name = var.group
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "dns" {
  name                = "nic-${var.workload}-dns"
  location            = var.location
  resource_group_name = var.group

  ip_configuration {
    name                          = "dns"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dns.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "dns" {
  name                  = "vm-${var.workload}-dns"
  resource_group_name   = var.group
  location              = var.location
  size                  = "Standard_B1s"
  admin_username        = "dnsadmin"
  admin_password        = "P@ssw0rd.123"
  network_interface_ids = [azurerm_network_interface.dns.id]

  custom_data = filebase64("${path.module}/cloud-init.sh")

  admin_ssh_key {
    username   = "dnsadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "osdisk-${var.workload}-dns"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  lifecycle {
    ignore_changes = [
      custom_data
    ]
  }
}

resource "azurerm_private_dns_a_record" "dns" {
  name                = "dns.bluefactory.local"
  zone_name           = var.zone_name
  resource_group_name = var.group
  ttl                 = 3600
  records             = [azurerm_network_interface.dns.private_ip_address]
}
