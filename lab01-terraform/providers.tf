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
  client_id       = "635aac5d-4eb1-4be5-a88c-ed97d9121d28"
  client_secret   = "sNH8Q~pRVcwOz~u5XH9pTFVeswoA6VaoTqScHblc"
  tenant_id       = "f958e84a-92b8-439f-a62d-4f45996b6d07"
}

