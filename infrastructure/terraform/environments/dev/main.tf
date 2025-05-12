terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

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

  system_node_count     = 2
  system_node_min_count = 1
  system_node_max_count = 4
  system_node_vm_size   = "Standard_D2s_v3"
  user_node_count       = 2
  user_node_min_count   = 1
  user_node_max_count   = 4
  user_node_vm_size     = "Standard_D4s_v3"

  service_cidr   = "10.0.4.0/24"
  dns_service_ip = "10.0.4.10"

  tags = local.tags
}
