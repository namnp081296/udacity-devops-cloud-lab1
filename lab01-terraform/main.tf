# Create Availability Set and Get Data
resource "azurerm_availability_set" "lab01-avlset" {
  name                = var.availability_set_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

data "azurerm_availability_set" "lab01-avlset" {
  name                = var.availability_set_name
  depends_on          = [azurerm_availability_set.lab01-avlset]
  resource_group_name = var.resource_group_name
}

# Create Virtual Network
resource "azurerm_virtual_network" "lab01-virnet" {
  name                = "${var.resource_group_name}-VirNet"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

# Create Subnet
resource "azurerm_subnet" "lab01-rsg-subnet" {
  name = "${var.resource_group_name}-subnet"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.lab01-virnet.name
  address_prefixes = ["10.0.2.0/24"]
}

# Create Public IP
resource "azurerm_public_ip" "lab01-rsg-pubip" {
  name                = "Lab01-PubIP"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

# Create Load Balancer
resource "azurerm_lb" "lab01-lb" {
  name                = "Lab01-LoadBalancer"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "LB-PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lab01-rsg-pubip.id
  }
}

# Create Load Balancer Address Pool
resource "azurerm_lb_backend_address_pool" "lab01-lb-addrpool" {
  loadbalancer_id = azurerm_lb.lab01-lb.id
  name            = "LB-BackEndAddressPool"
}

# Create NIC
resource "azurerm_network_interface" "lab01-rsg-nic" {
  count               = var.counts
  name                = "${var.resource_group_name}-NIC-${count.index}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  
  ip_configuration {
    name                          = "${var.resource_group_name}-NIC-${count.index}"
    subnet_id                     = element(azurerm_subnet.lab01-rsg-subnet[*].id, count.index % 4)
    private_ip_address_allocation = "Dynamic"
  }
}

# Create NIC Backend Address Pool Association
resource "azurerm_network_interface_backend_address_pool_association" "lab01-backendaddrpool-association" {
  count                   = var.counts
  network_interface_id    = element(azurerm_network_interface.lab01-rsg-nic[*].id, count.index % 4)
  ip_configuration_name   = "${var.resource_group_name}-NIC-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lab01-lb-addrpool.id
}

# Create Network Security Group
resource "azurerm_network_security_group" "lab01-rsg-nsg" {
  name                = "Lab01NSG"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "DenyDirectAccessFromtheInternet"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowInboundInternal"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }
  security_rule {
    name                       = "AllowOutboundInternal"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }
  security_rule {
    name                       = "AllowHTTPIncome"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Get image data
data "azurerm_image" "lab01-packer-img" {
  name                = var.image_name
  resource_group_name = var.image_resource_group
}

# Create Linux VM
resource "azurerm_virtual_machine" "lab01-rsg-linux-vm" {
  count                             = var.counts
  name                              = "${var.resource_group_name}-vm-${count.index}"
  resource_group_name               = var.resource_group_name
  location                          = var.resource_group_location
  vm_size                           = var.size_vm

  # Create NIC per VM
  network_interface_ids = [element(azurerm_network_interface.lab01-rsg-nic[*].id, count.index)]

  storage_image_reference {
    id = "${data.azurerm_image.lab01-packer-img.id}"
  }

  storage_os_disk {
    name              = "linux-vm-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.resource_group_name}-vm"
    admin_username = var.admin_usr  
    admin_password = var.admin_pwd
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  tags = {
    environment = "Lab01-Production"
  }
  availability_set_id = "${data.azurerm_availability_set.lab01-avlset.id}"

}