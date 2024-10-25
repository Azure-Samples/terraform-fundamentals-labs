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

locals {
  subnets = cidrsubnets("10.0.0.0/24", 6, 7, 8)
}

resource "azurerm_resource_group" "demo" {
  for_each = var.resource_groups
  name     = "${var.prefix}_${each.value}"
  location = var.region
  tags     = var.tags
}

/*
resource "azurerm_resource_group" "temp_resource_group_1" {
  name     = "temp_rg1"
  location = "UK South"

  tags = {
    reference = data.azurerm_resource_group.temp_resource_group_2.id
  }
}

data "azurerm_resource_group" "temp_resource_group_2" {
  name = "temp_rg2"
}
*/