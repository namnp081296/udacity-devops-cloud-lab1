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
  subscription_id = "456cc604-544c-45f8-99d0-c1b73aeec440"
  client_id       = "099fd190-7e02-48c9-9147-c98f61234409"
  client_secret   = ".rK8Q~f85VfgSQKEe4llRlBoqkup~57UYNLMbdgk"
  tenant_id       = "f958e84a-92b8-439f-a62d-4f45996b6d07"
}

