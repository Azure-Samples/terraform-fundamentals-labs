# main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.34.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rgs" {
  count    = length(var.rg_names)
  name     = "${var.prefix}_${var.rg_names[count.index]}"
  location = var.region
  tags     = var.tags
}


# usage: random_integer.suffix.result

# resource "random_integer" "suffix" {
#   min     = 1
#   max     = 50000 
# }
