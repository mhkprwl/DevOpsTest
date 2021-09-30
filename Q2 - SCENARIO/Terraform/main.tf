# -
# - Create Resource Group
resource "azurerm_resource_group" "rg" {
  name = var.rgname
  location = var.location
}
###############################################################################################
# -
# - Create Virtual network
# -
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnetname
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}
###############################################################################################
# -
# - Create Subnets
# -
resource "azurerm_subnet" "websubnet" {
  name                                           = var.websubnetname
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  resource_group_name                            = azurerm_resource_group.rg.name
  address_prefixes                               = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "appsubnet" {
  name                                           = var.appsubnetname
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  resource_group_name                            = azurerm_resource_group.rg.name
  address_prefixes                               = ["10.0.2.0/24"]
}
###############################################################################################
# -
# - Create Network Security Groups - Association with Subnets - Rules
# -
resource "azurerm_network_security_group" "webnsg" {
  name                = var.webnsgname
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "appnsg" {
  name                = var.appnsgname
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "web-assc" {
  subnet_id                 = azurerm_subnet.websubnet.id
  network_security_group_id = azurerm_network_security_group.webnsg.id
}

resource "azurerm_subnet_network_security_group_association" "app-assc" {
  subnet_id                 = azurerm_subnet.appsubnet.id
  network_security_group_id = azurerm_network_security_group.appnsg.id
}

resource "azurerm_network_security_rule" "webnsgrule1" {
  name                        = "IBA-AzureLoadBalancer"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  source_port_ranges           = null
  destination_port_range      = "*"
  destination_port_ranges     = null 
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.webnsg.name
}

resource "azurerm_network_security_rule" "webnsgrule2" {
  name                        = "IBA-Inbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_port_ranges          = null
  destination_port_ranges     = ["80","443"]
  destination_port_range      = null 
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.webnsg.name
}

resource "azurerm_network_security_rule" "webnsgrule3" {
  name                        = "IBD-All"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  source_port_ranges          = null
  destination_port_range      = "*"
  destination_port_ranges     = null
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.webnsg.name
}

resource "azurerm_network_security_rule" "appnsgrule1" {
  name                        = "IBA-AzureLoadBalancer"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  source_port_ranges          = null
  destination_port_range      = "*"
  destination_port_ranges     = null 
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.appnsg.name
}

resource "azurerm_network_security_rule" "appnsgrule1" {
  name                        = "IBA-App-Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  source_port_ranges          = null
  destination_port_range      = null
  destination_port_ranges     = ["80","443"] 
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.appnsg.name
}

resource "azurerm_network_security_rule" "appnsgrule2" {
  name                        = "IBD-All"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  source_port_ranges           = null
  destination_port_range      = "*"
  destination_port_ranges     = null
  source_address_prefix       = "*"
  destination_address_prefix  = "*" 
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.appnsg.name
}
###############################################################################################

data "azurerm_client_config" "current" {}

# -
# - Create Azure Keyvault - Access Policy - Secrets
# -

resource "azurerm_key_vault" "poc" {
  name                = var.kvname
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name = "standard"
}

resource "random_string" "webvmpassword" {
  length           = 32
  special          = true
  override_special = "/@"
}

resource "random_string" "appvmpassword" {
  length           = 32
  special          = true
  override_special = "/@"
}

resource "azurerm_key_vault_secret" "webvm" {
  name         = "${var.webvmnic}-password"
  value        = random_string.webvmpassword.result
  key_vault_id = azurerm_key_vault.poc.id
  depends_on = [azurerm_key_vault_access_policy.policy]
}

resource "azurerm_key_vault_secret" "appvm" {
  name         = "${var.appvmnic}-password"
  value        = random_string.appvmpassword.result
  key_vault_id = azurerm_key_vault.poc.id
  depends_on = [azurerm_key_vault_access_policy.policy]
}

resource "azurerm_key_vault_access_policy" "policy" {
  key_vault_id              = azurerm_key_vault.poc.id
  tenant_id                 = var.tenant_id
  object_id                 = var.object_id
  secret_permissions        = ["Get", "List","Set"]
  key_permissions           = ["Get","List","Update", "Create","Import","Decrypt","Encrypt","UnwrapKey","WrapKey"]
  certificate_permissions   = ["Get","List","Create","Import","Update"]
  storage_permissions       = []
}

###############################################################################################
# -
# - Create Storage Account
# -

resource "azurerm_storage_account" "poc" {
  name                     = var.saname
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

###############################################################################################
# -
# - Create Virtual Machine Nics
# -

resource "azurerm_network_interface" "webvmnic" {
  name                = var.webvmnic
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "web-internal"
    subnet_id                     = azurerm_subnet.websubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "appvmnic" {
  name                = var.appvmnic
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "app-internal"
    subnet_id                     = azurerm_subnet.appsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
###############################################################################################

# -
# - Create Windows Virtual Machine
# -

resource "azurerm_windows_virtual_machine" "webvm" {
  name                = var.webvmname
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B1s"
  network_interface_ids = [
    azurerm_network_interface.webvmnic.id
  ]
  admin_username      = var.vm_admin_username
  admin_password      = random_string.webvmpassword.result
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  lifecycle {
    ignore_changes = [
      admin_password
    ]
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "appvm" {
  name                = var.appvmname
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B1s"
  network_interface_ids = [
    azurerm_network_interface.appvmnic.id
  ]
  admin_username      = var.vm_admin_username
  admin_password      = random_string.appvmpassword.result
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  lifecycle {
    ignore_changes = [
      admin_password
    ]
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
