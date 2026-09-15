# Policy 1 — require the `env` tag on resources (audit)
resource "azurerm_resource_group_policy_assignment" "require_env_tag" {
  name                 = "require-env-tag"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
  display_name         = "Require 'env' tag on resources"
  description          = "Audits resources that are missing the 'env' tag (non-blocking)."
  enforce              = false

  parameters = jsonencode({
    tagName = {
      value = var.required_tag_name
    }
  })
}

# Policy 2 — allowed locations (deny)
resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  display_name         = "Allowed locations"
  description          = "Restricts resources to approved Azure regions."

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })
}

# Policy 3 — AMA audit on Linux Arc machines (audit)
resource "azurerm_resource_group_policy_assignment" "ama_audit_linux_arc" {
  name                 = "ama-audit-linux-arc"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/f17d891d-ff20-46f2-bad3-9e0a5403a4d3"
  display_name         = "Linux Arc machines should have AMA installed"
  description          = "Audits Linux Arc-enabled machines that do not have the Azure Monitor Agent installed."
}
