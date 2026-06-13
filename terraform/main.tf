##############################################################################
# main.tf
# Terraform core: required providers, remote backend, and data sources.
# Everything else lives in its own dedicated file.
##############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Remote state stored in Azure Storage Account
  # Run terraform/bootstrap.sh ONCE before terraform init
  backend "azurerm" {
    resource_group_name  = "zurimarket-tfstate-rg"
    storage_account_name = "zurimarkettfstate"
    container_name       = "tfstate"
    key                  = "zurimarket.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Current Azure login context — used for tenant_id and object_id in Key Vault
data "azurerm_client_config" "current" {}

# Random 6-char suffix — keeps Key Vault name globally unique
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
