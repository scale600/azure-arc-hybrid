output "assignment_ids" {
  description = "Map of policy assignment resource IDs"
  value = {
    require_env_tag     = azurerm_resource_group_policy_assignment.require_env_tag.id
    allowed_locations   = azurerm_resource_group_policy_assignment.allowed_locations.id
    ama_audit_linux_arc = azurerm_resource_group_policy_assignment.ama_audit_linux_arc.id
  }
}
