---
layout: page
title: Remote State
description: Lab 7 - Part 1 - Remote state
---

## Lab description

In this lab we learn about Terraform remote state.

## Know how to secure the state file using `tf-backend`

### Setup

Make sure you are in the correct folder:

```powershell
cd ~/terraform-labs
```

```bash
cd ~/terraform-labs
```

If you were unable to complete the last lab, you can find a copy of the files in the [solutions folder]({{ site.github.repository_url }}/tree/main/docs/06-modules/solutions/01)

### 1. Create a storage account and a blob container to hold the state file

1. Use your new found knowledge of Terraform to create a storage account and a blob container to hold the state file by applying this Terraform module:

    ```terraform
    variable "location" {
      type    = string
      default = "uksouth"
    }
    
    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
        random = {
          source  = "hashicorp/random"
          version = "~> 3.0"
        }
      }
    }
    
    provider "azurerm" {
      features {}
      storage_use_azuread = true
    }
    
    locals {
      postfix = random_pet.pet.id
    }
    
    data "azurerm_client_config" "current" {}
    
    resource "random_pet" "pet" {
      length    = 2
      separator = "-"
    }
    
    resource "azurerm_resource_group" "state" {
      name     = "rg-state-${local.postfix}"
      location = var.location
    }
    
    resource "azurerm_storage_account" "state" {
      name                          = "ststate${replace(local.postfix, "-", "")}"
      resource_group_name           = azurerm_resource_group.state.name
      location                      = azurerm_resource_group.state.location
      account_tier                  = "Standard"
      account_replication_type      = "LRS"
      shared_access_key_enabled     = false
      public_network_access_enabled = true # Do not do this in production
    }
    
    resource "azurerm_storage_container" "state" {
      name                  = "tfstate"
      storage_account_name  = azurerm_storage_account.state.name
      container_access_type = "private"
    }
    
    resource "azurerm_role_assignment" "state" {
      scope                = azurerm_storage_container.state.resource_manager_id
      role_definition_name = "Storage Blob Data Owner"
      principal_id         = data.azurerm_client_config.current.object_id
    }
    
    output "storage_account_details" {
      value = {
        resource_group_name  = azurerm_storage_account.state.resource_group_name
        storage_account_name = azurerm_storage_account.state.name
        container_name       = azurerm_storage_container.state.name
      }
    }
    ```

2. Take note of the output values, you will need them later.

### 3. Update the `terraform` block in `main.tf` to include the backend configuration

1. Update `main.tf` and add a `backend` block

    ```terraform
    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
      }
      backend "azurerm" {}
    }
    ```

    Note that the `backend` block is empty. This is because we will be using the `init` command to configure the backend.

### 4. Initialize the backend

1. Run init

    ```powershell
    terraform init `
        -backend-config="resource_group_name=<your_resource_group_name>" `
        -backend-config="storage_account_name=<your_storage_account_name>" `
        -backend-config="container_name=tfstate" `
        -backend-config="key=terraform.tfstate" `
        -backend-config="use_azuread_auth=true"
    ```

    ```bash
    terraform init \
        -backend-config="resource_group_name=<your_resource_group_name>" \
        -backend-config="storage_account_name=<your_storage_account_name>" \
        -backend-config="container_name=tfstate" \
        -backend-config="key=terraform.tfstate" \
        -backend-config="use_azuread_auth=true"
    ```

2. The output from init should setup a remote backend and prompt you to migrate you local state to the remote backend.

    ```text
    Initializing the backend...
    Do you want to copy existing state to the new backend?
      Pre-existing state was found while migrating the previous "local" backend to the
      newly configured "azurerm" backend. No existing state was found in the newly
      configured "azurerm" backend. Do you want to copy this state to the new "azurerm"
    backend? Enter "yes" to copy and "no" to start with an empty state.
    ```

3. Type `yes` and hit enter.

### 5. Plan and apply

1. Run `terraform apply` to and ensure there are no changes.

### 6. Verify

* Verify the resources that were created
* Take a look at the state file in the blob container of your storage account and make sure it's updated too.
* There shouldn't be any more local state file in the folder.

### 7. Recap

* AzureRM Backend - <https://developer.hashicorp.com/terraform/language/backend/azurerm>

---
