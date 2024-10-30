locals {
  subnets = { for subnet in flatten([
    for virtual_network_key, virtual_network_value in var.virtual_networks : [
      for subnet_key, subnet_value in virtual_network_value.subnets : {
        composite_key        = "${virtual_network_key}-${subnet_key}"
        name                 = subnet_value.name == null ? "${virtual_network_value.name}-${subnet_key}" : subnet_value.name
        address_prefix       = subnet_value.address_prefix
        resource_group_name  = azurerm_resource_group.demo[virtual_network_value.resource_group_key].name
        virtual_network_name = azurerm_virtual_network.demo[virtual_network_key].name
      }
    ]
  ]) : subnet.composite_key => subnet }
}

resource "azurerm_resource_group" "demo" {
  for_each = var.resource_groups
  name     = "${var.prefix}_${each.value}"
  location = var.region
  tags     = var.tags
}

resource "azurerm_virtual_network" "demo" {
  for_each            = var.virtual_networks
  name                = each.value.name
  address_space       = each.value.address_space
  location            = var.region
  resource_group_name = azurerm_resource_group.demo[each.value.resource_group_key].name
}

resource "azurerm_subnet" "demo" {
  for_each             = local.subnets
  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = [each.value.address_prefix]
}