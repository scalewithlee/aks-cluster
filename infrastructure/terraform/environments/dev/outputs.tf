output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.foundation.resource_group_name
}

output "aks_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.aks_name
}

output "aks_host" {
  description = "The Kubernetes cluster server host"
  value       = module.aks.host
  sensitive   = true
}

output "aks_kube_config" {
  description = "The kubeconfig for the AKS cluster"
  value       = module.aks.kube_config
  sensitive   = true
}

output "kube_config_command" {
  description = "Command to configure kubectl"
  value       = "az aks get-credentials --resource-group ${module.foundation.resource_group_name} --name ${module.aks.aks_name}"
}

output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = module.foundation.acr_name
}

output "acr_login_server" {
  description = "The login server URL for the Azure Container Registry"
  value       = module.foundation.acr_login_server
}

output "acr_login_command" {
  description = "Command to log in to the Azure Container Registry"
  value       = "az acr login --name ${module.foundation.acr_name}"
}
