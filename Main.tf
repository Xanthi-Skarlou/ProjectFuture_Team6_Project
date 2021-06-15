# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }


#   #Terraform Cloud
#   backend "remote" {
#     organization = "ProjectFutureTeam6"
#     workspaces {
#       name = "team6Workspace"
#     }
#   }
}

provider "azurerm" {
  features {}
}

# provider "azurerm" {
#   features {}
#   subscription_id = var.subscription_id
#   client_id       = var.client_appId
#   client_secret   = var.client_password
#   tenant_id       = var.tenant_id
# }


#Create resource group
resource "azurerm_resource_group" "main" {
    name    = "${var.prefix}-rg"
    location = var.location
}


# Create virtual network
# fundamental building block for your private network
# communication of Azure resources with the internet, 
# communication between Azure resources, 
# communication with on-premises resources, 
# filtering network traffic, routing network traffic, and integration with Azure services
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}TFVnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.rg
  tags                = var.tags
}

# Create subnet in the existing virtual network
resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-ci-cd-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes       = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-PublicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  tags                = var.tags
}

# Create Network Security Group and rule
# Network Security Groups control the flow of network traffic in and out of your VM.
resource "azurerm_network_security_group" "main" {
  name                = "${terraform.worksapce}-NSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Network Interface
# A virtual network interface card (NIC) connects your VM to a given virtual network, 
# public IP address, and network security group. 
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "main" {
    network_interface_id      = azurerm_network_interface.main.id
    network_security_group_id = azurerm_network_security_group.main.id
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "main" {
  name                  = "${terrafrom.workspace}-VM"
  location              = var.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"
  tags                  = var.tags

  storage_os_disk {
    name              = "${var.prefix}OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}VM"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}
































