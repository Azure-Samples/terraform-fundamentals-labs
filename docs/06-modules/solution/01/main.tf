terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "demo" {
  source = "./modules/demo"

  prefix = var.prefix
  region = var.region
  resource_groups = var.resource_groups
  virtual_networks = var.virtual_networks
  tags = var.tags
}

moved {
  from = azurerm_resource_group.demo
  to   = module.demo.azurerm_resource_group.demo
}

moved {
  from = azurerm_virtual_network.demo
  to   = module.demo.azurerm_virtual_network.demo
}

moved {
  from = azurerm_subnet.demo
  to   = module.demo.azurerm_subnet.demo
}