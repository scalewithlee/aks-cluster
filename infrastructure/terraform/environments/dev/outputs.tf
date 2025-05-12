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
