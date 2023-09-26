resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = "eastus"
}
data "azurerm_subnet" "subnet" {
  name                 = var.subnet
  virtual_network_name = var.virtual_network
  resource_group_name  = var.resource_group
}
resource "azurerm_public_ip" "publicip" {
    name                         = "myPublicIP"
    location                     = "${data.azurerm_resource_group.rg.location}"
    resource_group_name          = "${data.azurerm_resource_group.rg.name}"
    public_ip_address_allocation = "dynamic"
}
resource "azurerm_network_interface" "nic-card" {
  name                = "nic-card"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.publicip.id}"
  }
}
count = 11
  name = "CUSPVMSNRPT0${count.index + 1}"
  azurerm_resource_group = "${azurerm_resource_group.rg.id}"
  network_interface_ids = ["${azurerm_network_interface.nic-card.id}"]
  vm_hostname = "CUSPVMSNRPT${count.index + 1}"
  location ="${azurerm_network_interface.nic-card.location}"
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

