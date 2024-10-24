# outputs.tf
output "rg_ids" {    
    value = azurerm_resource_group.rgs.*.id   
}

# or
# value = [for rg in azurerm_resource_group.rgs : rg.id]     