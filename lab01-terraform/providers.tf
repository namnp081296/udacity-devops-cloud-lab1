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
  subscription_id = "c761712a-772e-4832-b4d5-73b3a4b12e0b"
  client_id       = "a0965861-c85c-4a46-82e5-265e8042ea66"
  client_secret   = "_kn8Q~3tuOkIzDO5rolDR5cSPYjVDupACJr3Abi9"
  tenant_id       = "f958e84a-92b8-439f-a62d-4f45996b6d07"
}

