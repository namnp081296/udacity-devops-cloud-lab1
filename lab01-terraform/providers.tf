terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.46.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "2fd8f952-d489-45bc-a39a-aeb5b6aff6d2"
  client_id       = "7ea4e969-3318-46f9-8659-e2388f60a964"
  client_secret   = "XJr8Q~LVXAzntOKJ3H9jxN02bvoK5idnPgHOMckQ"
  tenant_id       = "f958e84a-92b8-439f-a62d-4f45996b6d07"
}

