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

resource "azurerm_resource_group" "contoso_rg" {
  name     = "${var.prefix}_rg"
  location = var.region
  tags     = var.tags
}

resource "azurerm_resource_group" "contoso_dev_rg" {
  name     = "${var.prefix}_dev_rg"
  location = var.region
  tags     = var.tags
}