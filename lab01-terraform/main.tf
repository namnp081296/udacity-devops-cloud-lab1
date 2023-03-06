resource "azurerm_resource_group" "lab01-rsg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "lab01-virnet" {
  name                = "${var.resource_group_name}-VirNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lab01-rsg.location
  resource_group_name = azurerm_resource_group.lab01-rsg.name
}

resource "azurerm_subnet" "lab01-rsg-subnet" {
  name = "${var.resource_group_name}-subnet"
  resource_group_name = azurerm_resource_group.lab01-rsg.name
  virtual_network_name = azurerm_virtual_network.lab01-virnet.name
  address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "lab01-rsg-pubip" {
  name                = "Lab01-PubIP"
  location            = azurerm_resource_group.lab01-rsg.location
  resource_group_name = azurerm_resource_group.lab01-rsg.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lab01-lb" {
  name                = "Lab01-LoadBalancer"
  location            = azurerm_resource_group.lab01-rsg.location
  resource_group_name = azurerm_resource_group.lab01-rsg.name

  frontend_ip_configuration {
    name                 = "LB-PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lab01-rsg-pubip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lab01-lb-addrpool" {
  loadbalancer_id = azurerm_lb.lab01-lb.id
  name            = "LB-BackEndAddressPool"
}

resource "azurerm_network_interface" "lab01-rsg-nic" {
  count               = var.counts
  name                = "${var.resource_group_name}-NIC-${count.index}"
  location            = azurerm_resource_group.lab01-rsg.location
  resource_group_name = azurerm_resource_group.lab01-rsg.name
  
  ip_configuration {
    name                          = "${var.resource_group_name}-NIC-Internal"
    subnet_id                     = azurerm_subnet.lab01-rsg-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "lab01-rsg-nsg" {
  name                = "lab01-rsg-NSG"
  location            = azurerm_resource_group.lab01-rsg.location
  resource_group_name = azurerm_resource_group.lab01-rsg.name
}

resource "azurerm_network_security_rule" "lab01-rsg-nsr" {
  name                         = "lab01-rsg-NSR"
  priority                     = 100
  direction                    = "Inbound"
  access                       = "Deny"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefix   = "*"
  resource_group_name          = azurerm_resource_group.lab01-rsg.name
  network_security_group_name  = azurerm_network_security_group.lab01-rsg-nsg.name
}

data "azurerm_image" "lab01-packer-img" {
  name                = var.image_name
  resource_group_name = var.image_resource_group
}

resource "azurerm_linux_virtual_machine" "lab01-rsg-linux-vm" {
  count                           = var.counts
  name                            = "${var.resource_group_name}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.lab01-rsg.name
  location                        = azurerm_resource_group.lab01-rsg.location
  size                            = var.size_vm
  admin_username                  = var.admin_usr
  admin_password                  = var.admin_pwd
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.lab01-rsg-nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = "${data.azurerm_image.lab01-packer-img.id}"
}

