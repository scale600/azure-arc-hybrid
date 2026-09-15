module "resource_group" {
  source   = "./modules/resource-group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.workspace_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

module "policy" {
  source            = "./modules/policy"
  resource_group_id = module.resource_group.id
}
