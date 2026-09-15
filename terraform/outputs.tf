output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID"
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = azurerm_log_analytics_workspace.this.name
}
