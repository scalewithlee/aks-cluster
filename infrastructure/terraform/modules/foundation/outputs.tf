output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.this.id
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.this.name
}

output "aks_subnet_id" {
  description = "The ID of the AKS subnet"
  value       = azurerm_subnet.aks.id
}

output "aks_nsg_id" {
  description = "The ID of the AKS network security group"
  value       = azurerm_network_security_group.aks.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "acr_id" {
  description = "The ID of the container registry"
  value       = azurerm_container_registry.this.id
}

output "acr_name" {
  description = "The name of the container registry"
  value       = azurerm_container_registry.this.name
}

output "acr_login_server" {
  description = "The login server URL for the container registry"
  value       = azurerm_container_registry.this.login_server
}
