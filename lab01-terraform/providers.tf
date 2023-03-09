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
  subscription_id = "dfbd8d6e-c77f-414e-a3f4-14c567b43de3"
  client_id       = "49553a3a-9504-47d3-830e-90244c16151c"
  client_secret   = "kw68Q~TY-KWJa-Ujpp6bZZ27j1Pte_EJZCoc4bR-"
  tenant_id       = "f958e84a-92b8-439f-a62d-4f45996b6d07"
}

