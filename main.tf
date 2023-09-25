resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = "eastus"
}
resource "azurerm_public_ip" "public_ip" {
  name                = "${random_pet.prefix.id}-public-ip"
  location            = azurerm_resource_group.rg.location
  azurerm_resource_group = azurerm_resource_group.rg.id
  allocation_method   = "Dynamic"
}
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network
  location            = azurerm_resource_group.rg.location
  azurerm_resource_group = azurerm_resource_group.rg.id
}
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet
  azurerm_resource_group = azurerm_resource_group.rg.id
}
resource "azurerm_network_interface" "Windows-nic" {
  name                = "${random_pet.prefix.id}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

   ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}
resource "random_password" "password" {
  length  = 16
  special = true
  lower   = true
  upper   = true
  numeric = true
}

resource "azurerm_windows_virtual_machine" "Virtual_Machine" {
  count = 11
  name = "CUSPVMSNRPT0${count.index + 1}"
  azurerm_resource_group = azurerm_resource_group.rg.id
  azurerm_virtual_network = azurerm_virtual_network.vnet.id
  vm_hostname = "CUSPVMSNRPT${count.index + 1}"
  is_windows_image = true
  azurerm_subnet = azurerm_subnet.subnet.id
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  location = azurerm_resource_group.rg.location
  size = "D4as_v4"
  admin_username = "adminuser"
  admin_password = random_password.password.result

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  tags = {
    Environment = "production"
    Application = "SNF"
    Workload = "SNF"
  }
}