# core_workflow

# Specifiy the provider and version
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.34.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "contoso_rg" {
  name     = "contoso_rg"
  location = "UK South"

  tags = {
    "cost_center" = "contoso research"
  }
}

resource "azurerm_resource_group" "contoso_rg_dev" {
  name     = "contoso_rg_dev"
  location = "UK South"

  tags = {
    "cost_center" = "contoso research again"
  }
}


# az group list | jq '.[] | select(.name == "contoso_rg")'
# az group list | jq '.[].name'
