output "rg_ids" {    
    value = azurerm_resource_group.rgs.*.id   
}

output "vnet_ids" {    
    value = azurerm_virtual_network.vnets.*.id   
}