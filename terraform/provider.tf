terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "arc-hybrid-lab"
    storage_account_name = "archylabtfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }
}

# Authenticates via the Azure CLI (`az login`) locally, or via OIDC
# environment variables (ARM_*) in GitHub Actions (see M6).
provider "azurerm" {
  features {}
}
