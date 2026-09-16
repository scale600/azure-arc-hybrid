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

output "vm_public_ip" {
  description = "Public IP address of the hybrid-networking VM"
  value       = module.vm.public_ip
}

output "vm_private_ip" {
  description = "Private IP address of the hybrid-networking VM"
  value       = module.vm.private_ip
}
