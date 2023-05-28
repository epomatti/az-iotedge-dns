resource "azurerm_public_ip" "proxy" {
  name                = "pip-${var.workload}-proxy"
  resource_group_name = var.group
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "proxy" {
  name                = "nic-${var.workload}-proxy"
  location            = var.location
  resource_group_name = var.group

  ip_configuration {
    name                          = "dns"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.proxy.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "proxy" {
  name                  = "vm-${var.workload}-proxy"
  resource_group_name   = var.group
  location              = var.location
  size                  = "Standard_B1s"
  admin_username        = "proxy"
  admin_password        = "P@ssw0rd.123"
  network_interface_ids = [azurerm_network_interface.proxy.id]

  # custom_data = filebase64("${path.module}/cloud-init.sh")

  admin_ssh_key {
    username   = "proxy"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "osdisk-${var.workload}-proxy"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "cloud-infrastructure-services"
    offer     = "reverse-proxy-nginx"
    sku       = "reverse-proxy-nginx"
    version   = "0.0.3"
  }

  lifecycle {
    ignore_changes = [
      custom_data
    ]
  }
}

resource "azurerm_private_dns_a_record" "proxy" {
  name                = "proxy.bluefactory.local"
  zone_name           = var.zone_name
  resource_group_name = var.group
  ttl                 = 3600
  records             = [azurerm_network_interface.proxy.private_ip_address]
}
