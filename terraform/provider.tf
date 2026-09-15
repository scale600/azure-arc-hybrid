terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Authenticates via the Azure CLI (`az login`) locally, or via OIDC
# environment variables (ARM_*) in GitHub Actions (see M6).
provider "azurerm" {
  features {}
}
