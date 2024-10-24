
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.34.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "contoso"
    storage_account_name = "tfdemos"
    container_name       = "livedemo"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "contoso_rg" {
  name     = "contoso_live_demo_rg"
  location = "UK South"

  tags = {
    "purpose" = "remote state"
  }
}
