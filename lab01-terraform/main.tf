resource "azurerm_resource_group" "newrsg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "newrsg-virnet" {
  name                = "${var.resource_group_name}-VirNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.newrsg.location
  resource_group_name = azurerm_resource_group.newrsg.name
}

resource "azurerm_subnet" "newrsg-subnet" {
  name = "${var.resource_group_name}-subnet"
  resource_group_name = azurerm_resource_group.newrsg.name
  virtual_network_name = azurerm_virtual_network.newrsg-virnet.name
  address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "newrsg-pubip" {
  count               = var.counts
  name                = "newreg-pubIP-${count.index}"
  location            = azurerm_resource_group.newrsg.location
  resource_group_name = azurerm_resource_group.newrsg.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "example" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}


resource "azurerm_network_interface" "newrsg-nic" {
  count               = var.counts
  name                = "${var.resource_group_name}-NIC-${count.index}"
  location            = azurerm_resource_group.newrsg.location
  resource_group_name = azurerm_resource_group.newrsg.name
  
  ip_configuration {
    name                          = "${var.resource_group_name}-NIC-Internal"
    subnet_id                     = azurerm_subnet.newrsg-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.newrsg-pubip.*.id, count.index)
  }
}

resource "tls_private_key" "newrsg-ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "azurerm_network_security_group" "newrsg-nsg" {
  name                = "newrsg-NSG"
  location            = azurerm_resource_group.newrsg.location
  resource_group_name = azurerm_resource_group.newrsg.name
}

resource "azurerm_network_security_rule" "newrsg-nsr" {
  name                         = "newrsg-NSR"
  priority                     = 100
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "8080-9090"
  destination_port_range       = "8080-9090"
  source_address_prefix        = "*"
  destination_address_prefix   = "*"
  resource_group_name          = azurerm_resource_group.newrsg.name
  network_security_group_name  = azurerm_network_security_group.newrsg-nsg.name
}

resource "azurerm_linux_virtual_machine" "newrsg-linux-vm" {
  count                 = var.counts
  name                  = "${var.resource_group_name}-vm-${count.index}"
  resource_group_name   = azurerm_resource_group.newrsg.name
  location              = azurerm_resource_group.newrsg.location
  size                  = var.size_vm
  admin_username        = var.admin_usr
  network_interface_ids = [
    element(azurerm_network_interface.newrsg-nic.*.id, count.index)
  ]

  admin_ssh_key {
    username = var.admin_usr
    public_key = tls_private_key.newrsg-ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

