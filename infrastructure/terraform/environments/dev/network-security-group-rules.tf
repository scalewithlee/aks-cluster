# Example NSG rules for AKS
resource "azurerm_network_security_rule" "aks_http" {
  name                        = "allow-http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.foundation.resource_group_name
  network_security_group_name = element(split("/", module.foundation.aks_nsg_id), length(split("/", module.foundation.aks_nsg_id)) - 1)
}

resource "azurerm_network_security_rule" "aks_https" {
  name                        = "allow-https"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.foundation.resource_group_name
  network_security_group_name = element(split("/", module.foundation.aks_nsg_id), length(split("/", module.foundation.aks_nsg_id)) - 1)
}
