# Create Availability Set and Get Data
resource "azurerm_availability_set" "lab01-avlset" {
  name                = var.availability_set_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

data "azurerm_availability_set" "lab01-avlset" {
  name                = var.availability_set_name
  depends_on = [azurerm_availability_set.lab01-avlset]
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
  # count               = var.counts
  name                = "${var.resource_group_name}-NIC"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  
  ip_configuration {
    name                          = "${var.resource_group_name}-NIC"
    #subnet_id                     = element(azurerm_subnet.lab01-rsg-subnet.*.id, count.index)
    subnet_id                     = azurerm_subnet.lab01-rsg-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create NIC Backend Address Pool Association
resource "azurerm_network_interface_backend_address_pool_association" "lab01-backendaddrpool-association" {
  # count                   = var.counts
  # network_interface_id    = element(azurerm_network_interface.lab01-rsg-nic.*.id, count.index)
  network_interface_id    = azurerm_network_interface.lab01-rsg-nic.id
  ip_configuration_name   = "${var.resource_group_name}-NIC"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lab01-lb-addrpool.id
}

# Create Network Security Group
resource "azurerm_network_security_group" "lab01-rsg-nsg" {
  name                = "Lab01NSG"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "DenyDirectAccessFromtheInternet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowInternal"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }
}

# Get image data
data "azurerm_image" "lab01-packer-img" {
  name                = var.image_name
  resource_group_name = var.image_resource_group
}

# Create Linux VM
resource "azurerm_virtual_machine" "lab01-rsg-linux-vm" {
  # count                             = var.counts
  name                              = "${var.resource_group_name}-vm"
  resource_group_name               = var.resource_group_name
  location                          = var.resource_group_location
  vm_size                           = var.size_vm

  # network_interface_ids = [element(azurerm_network_interface.lab01-rsg-nic.*.id, count.index)]
  network_interface_ids = [azurerm_network_interface.lab01-rsg-nic.id]

  storage_image_reference {
    id = "${data.azurerm_image.lab01-packer-img.id}"
  }

  storage_os_disk {
    name              = "linux-vm-osdisk"
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

resource "azurerm_managed_disk" "lab01-managed-disk" {
  # count                = var.counts
  name                 = "${var.resource_group_name}-disk"
  location             = var.resource_group_location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "lab01-vm-data-disk-attach" {
  # count              = var.counts
  managed_disk_id    = azurerm_managed_disk.lab01-managed-disk.id
  virtual_machine_id = azurerm_virtual_machine.lab01-rsg-linux-vm.id
  lun                = "10"
  caching            = "ReadWrite"
}