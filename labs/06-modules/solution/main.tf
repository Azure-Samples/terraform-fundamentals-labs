# main.tf from calling module 
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.34.0"
    }
  }
}

provider "azurerm" {
  features {}
}


module "connectedrg" {
  
  source = "./modules/contoso-az-connectedrg" 

  # or remote git repo with ?ref=verion    
  # notice the //
  #source   = "<repo-server>/<username>/<repo-name>//contoso-az-connectedrg?ref=v1.0"
  
  rg_names = var.rg_names
  vnets    = var.vnets
}





