variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "environment" {
  description = "The environment (dev, stg, prod, etc.)"
  type        = string
}

variable "location" {
  description = "The Azure region in which to create resources"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the AKS cluster will be deployed"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for monitoring"
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version to use"
  type        = string
  default     = "1.32.0"
}

variable "system_node_min_count" {
  description = "The minimum number of system nodes in the AKS cluster"
  type        = number
  default     = 1
}

variable "system_node_max_count" {
  description = "The maximum number of system nodes in the AKS cluster"
  type        = number
  default     = 4
}

variable "system_node_vm_size" {
  description = "The VM size for the system nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "user_node_min_count" {
  description = "The minimum number of user nodes in the AKS cluster"
  type        = number
  default     = 1
}

variable "user_node_max_count" {
  description = "The maximum number of user nodes in the AKS cluster"
  type        = number
  default     = 4
}

variable "user_node_vm_size" {
  description = "The VM size for the user nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "service_cidr" {
  description = "The CIDR range for Kubernetes services"
  type        = string
  default     = "10.0.4.0/24"
}

variable "dns_service_ip" {
  description = "The IP address for Kubernetes DNS service"
  type        = string
  default     = "10.0.4.10"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "acr_id" {
  description = "The ID of the Azure Container Registry"
  type        = string
}
