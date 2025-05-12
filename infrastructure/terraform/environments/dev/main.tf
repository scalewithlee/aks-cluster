terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Add this to get current user data
data "azurerm_client_config" "current" {}

locals {
  prefix      = "aks"
  environment = "dev"
  location    = "eastus"
  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Project     = "aks-cluster"
  }
}

module "foundation" {
  source = "../../modules/foundation"

  prefix                    = local.prefix
  environment               = local.environment
  location                  = local.location
  vnet_address_space        = "10.0.0.0/16"
  aks_subnet_address_prefix = "10.0.0.0/22"
  tags                      = local.tags
}

module "aks" {
  source = "../../modules/aks"

  prefix              = local.prefix
  environment         = local.environment
  location            = local.location
  resource_group_name = module.foundation.resource_group_name
  subnet_id           = module.foundation.aks_subnet_id

  kubernetes_version         = "1.32.0"
  log_analytics_workspace_id = module.foundation.log_analytics_workspace_id

  system_node_min_count = 1
  system_node_max_count = 2
  system_node_vm_size   = "Standard_B2s"
  user_node_min_count   = 1
  user_node_max_count   = 2
  user_node_vm_size     = "Standard_B2s"

  service_cidr   = "10.0.4.0/24"
  dns_service_ip = "10.0.4.10"

  acr_id = module.foundation.acr_id

  tags = local.tags
}

resource "azurerm_role_assignment" "aks_admin" {
  scope                = module.aks.aks_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id

  # Add this to prevent destroy/recreate cycles if the principal_id changes temporarily during deployment
  lifecycle {
    ignore_changes = [
      # Ignore changes to principal_id to avoid issues during re-authentication
      principal_id,
    ]
  }
}