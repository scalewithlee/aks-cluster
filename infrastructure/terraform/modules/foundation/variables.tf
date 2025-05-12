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
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "The address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_subnet_address_prefix" {
  description = "The address prefix for the AKS subnet"
  type        = string
  default     = "10.0.0.0/22"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}
