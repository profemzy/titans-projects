resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.resource_group_name}-${var.environment}-nsg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_network" "aks_vn" {
  name                = "${var.resource_group_name}-${var.environment}-vn"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = ["10.0.0.0/8"]

  tags = {
    environment = var.environment
  }
}

# AKS Default Subnet
resource "azurerm_subnet" "aks-default" {
  name                 = "aks-${var.environment}-default"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vn.name
  address_prefixes     = ["10.240.0.0/16"]
}

## AKS Virtual Nodes Subnet
resource "azurerm_subnet" "aks-virtual-nodes" {
  name                 = "aks-${var.environment}-virtual-nodes"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vn.name
  address_prefixes     = ["10.241.0.0/16"]
}
