terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = "${var.prefix}-${var.environment}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.prefix}-${var.environment}"
  kubernetes_version  = var.kubernetes_version

  # System node pool configuration
  default_node_pool {
    name                        = "systempool"
    temporary_name_for_rotation = "temppool"
    vm_size                     = var.system_node_vm_size
    vnet_subnet_id              = var.subnet_id
    enable_auto_scaling         = true
    min_count                   = var.system_node_min_count
    max_count                   = var.system_node_max_count
    os_disk_size_gb             = 128
    type                        = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
    }
    tags = var.tags
  }

  # Identity for the cluster (managed)
  identity {
    type = "SystemAssigned"
  }

  # Add monitoring
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  # Configure cluster networking
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "azure"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  # Configure auto-upgrade to stable versions of kubernetes
  automatic_channel_upgrade = "stable"

  # Azure RBAC integration
  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }
}

# User node pool for workloads
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.user_node_vm_size
  vnet_subnet_id        = var.subnet_id
  enable_auto_scaling   = true
  min_count             = var.user_node_min_count
  max_count             = var.user_node_max_count
  os_disk_size_gb       = 128
  node_labels = {
    "nodepool-type" = "user"
    "environment"   = var.environment
  }
  tags = var.tags
}

resource "azurerm_role_assignment" "aks_to_acr" {
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}
