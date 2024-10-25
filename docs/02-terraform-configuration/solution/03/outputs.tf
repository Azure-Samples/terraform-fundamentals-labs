output "contoso_rg_id" {
  value       = azurerm_resource_group.contoso_rg.id
  description = "don't show actual data on cli output"
  sensitive   = true
}

output "contoso_dev_rg_id" {
  value = azurerm_resource_group.contoso_dev_rg.id
}