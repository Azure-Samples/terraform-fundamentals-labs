# locals {
#     prefix = "contoso"
#     region = "UK South"
#     tags = {
#         cost_center = "contoso research"
#     }
# }

# provider "azurerm" {
#     version = "~>3.34.0"
#     features {}    
# }

# resource "azurerm_resource_group" "contoso_rg" {
#     name = "${local.prefix}_rg"
#     location = local.region
#     tags = local.tags
# }


# resource "azurerm_resource_group" "contoso_dev_rg" {    
#     name = "${local.prefix}_dev_rg"
#     location = local.region
#     tags = local.tags
# }


# -------

# variable prefix {}

# variable region {           
#     type = string
#     default = "North Europe"
# }

# variable tags {
#     type= map          
# }

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
