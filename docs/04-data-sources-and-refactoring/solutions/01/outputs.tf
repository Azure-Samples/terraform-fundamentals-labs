output "resource_group_ids" {
  value       = { for key, value in azurerm_resource_group.demo : key => value.id }
  description = "Resource group ids"
}