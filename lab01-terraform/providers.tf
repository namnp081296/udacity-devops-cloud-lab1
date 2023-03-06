terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.46.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "e2bf10f5-b611-44c7-9617-4a26610fc460"
  client_id       = "504e75ea-1f30-4a71-a4af-a8aa3cb2fcd7"
  client_secret   = "37L8Q~Z0l4Ng8tetYSngYRzeN2VuYs44LP1o7cxv"
  tenant_id       = "f958e84a-92b8-439f-a62d-4f45996b6d07"
}

