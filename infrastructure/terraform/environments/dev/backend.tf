terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstatef2c8c2d6"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
