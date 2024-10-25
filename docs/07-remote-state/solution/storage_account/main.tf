variable "location" {
  type    = string
  default = "uksouth"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

locals {
  postfix = random_pet.pet.id
}

data "azurerm_client_config" "current" {}

resource "random_pet" "pet" {
  length    = 2
  separator = "-"
}

resource "azurerm_resource_group" "state" {
  name     = "rg-state-${local.postfix}"
  location = var.location
}

resource "azurerm_storage_account" "state" {
  name                          = "ststate${replace(local.postfix, "-", "")}"
  resource_group_name           = azurerm_resource_group.state.name
  location                      = azurerm_resource_group.state.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  shared_access_key_enabled     = false
  public_network_access_enabled = true # Do not do this in production
}

resource "azurerm_storage_container" "state" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "state" {
  scope                = azurerm_storage_container.state.resource_manager_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

output "storage_account_details" {
  value = {
    resource_group_name  = azurerm_storage_account.state.resource_group_name
    storage_account_name = azurerm_storage_account.state.name
    container_name       = azurerm_storage_container.state.name
  }
}