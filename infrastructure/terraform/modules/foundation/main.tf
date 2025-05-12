terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Resource group
resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location
  tags     = var.tags
}

# Virtual network
resource "azurerm_virtual_network" "this" {
  name                = "${var.prefix}-${var.environment}-vnet"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

# Subnet for AKS
resource "azurerm_subnet" "aks" {
  name                 = "${var.prefix}-${var.environment}-aks-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.aks_subnet_address_prefix]
}

# Network security group
resource "azurerm_network_security_group" "aks" {
  name                = "${var.prefix}-${var.environment}-aks-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks.id
}

# Log analytics workspace for monitoring
resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.prefix}-${var.environment}-law"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}
