output "resource_groups" {    
    value = module.connectedrg.rg_ids
}

output "vnets" {    
    value = module.connectedrg.vnet_ids
}