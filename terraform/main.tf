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
  # The presentation site (M8) uses Azure Static Web Apps, which is not
  # available in koreacentral — allow eastasia for it.
  allowed_locations = ["koreacentral", "eastasia"]
}

module "vm" {
  source               = "./modules/vm"
  resource_group_name  = module.resource_group.name
  location             = var.vm_location
  vm_name              = var.vm_name
  vm_size              = var.vm_size
  admin_ssh_public_key = var.admin_ssh_public_key
  ssh_source_ip        = var.ssh_source_ip
  tailscale_auth_key   = var.tailscale_auth_key
  tags                 = var.tags
}
