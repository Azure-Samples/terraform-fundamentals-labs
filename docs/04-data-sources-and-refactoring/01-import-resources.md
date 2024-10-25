---
layout: page
title: Data sources and refactoring
description: Lab 4 - Part 1 - Import resources and data sources
---

## Lab description

In this lab we learn about the `import` block and data sources in Terraform.

## Import existing resources and read data from external resources

### Setup

Make sure you are in the correct folder:

```powershell
cd ~/terraform-labs
```

```bash
cd ~/terraform-labs
```

If you were unable to complete the last lab, you can find a copy of the files in the [solutions folder]({{ site.github.repository_url }}/tree/main/docs/03-expressions-and-functions/solutions/02)

### 1. Create some resource groups using azure portal or cli in "UK South"

1. Create a couple of resource groups outside of terraform.

    ```powershell
    az group create --name temp_rg1 --location "UK South"
    az group create --name temp_rg2 --location "UK South"
    ```

    ```bash
    az group create --name temp_rg1 --location "UK South"
    az group create --name temp_rg2 --location "UK South"
    ```

2. Verify that the resource group is created

3. Append below code into `main.tf` (we are trying to create same resource group via terraform)

    We are also using a `data` block, so we can retrieve the `id` of `temp_rg2` resource group.

    ```terraform
    resource "azurerm_resource_group" "temp_resource_group_1" {
      name     = "temp_rg1"
      location = "UK South"
    
      tags = {
        reference = data.azurerm_resource_group.temp_resource_group_2.id
      }
    }
    
    data "azurerm_resource_group" "temp_resource_group_2" {
      name = "temp_rg2"
    }
    ```

### 2. Plan

1. Run a plan

    ```powershell
    terraform plan
    ```

    ```bash
    terraform plan
    ```

2. You should see something like below where terraform thinks `temp_rg1` is a new resource

    ```text
    Terraform will perform the following actions:
    
      # azurerm_resource_group.temp_resource_group_1 will be created
      + resource "azurerm_resource_group" "temp_resource_group_1" {
          + id       = (known after apply)
          + location = "uksouth"
          + name     = "temp_rg1"
          + tags     = {
              + "reference" = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/temp_rg2"
            }
        }
    
    Plan: 1 to add, 0 to change, 0 to destroy.
    ```

> **Data Source** - Also note that we are able to refer the id of `temp_rg2` resource group without any issues. This is because we are not trying to manage that resource, but only retrieving some details about it.

### 3. Apply (and observe the error)

1. Run an apply.

    ```powershell
    terraform apply -auto-approve
    ```

    ```bash
    terraform apply -auto-approve
    ```

2. Review the error

    ```text
    │ Error: A resource with the ID "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/temp_rg1" already exists - to be managed via Terraform this resource needs to be imported into the State. Please see the resource documentation for "azurerm_resource_group" for more information.
    │
    │   with azurerm_resource_group.temp_resource_group_1,
    │   on main.tf line 25, in resource "azurerm_resource_group" "temp_resource_group_1":
    │   25: resource "azurerm_resource_group" "temp_resource_group_1" {
    ```
  
    This is because terraform wasn't aware of this resource until it tried an apply.

### 3. Import

1. Add the following  `import` block to `main.tf` to import the resource group.

    Be sure to replace `<subscription-id>` with your subscription id.

    ```terraform
    import {
      to = azurerm_resource_group.temp_resource_group_1
      id = "/subscriptions/<subscription-id>/resourceGroups/temp_rg1"
    }
    ```

2. Run the apply again

    ```powershell
    terraform apply -auto-approve
    ```

    ```bash
    terraform apply -auto-approve
    ```

    > NOTE: An alternative approach is to use the CLI command `terraform import azurerm_resource_group.temp_resource_group_1 "/subscriptions/<subscription_id>/resourceGroups/temp_rg"`

3. You should see an output such as below

    ```text
    Plan: 1 to import, 0 to add, 1 to change, 0 to destroy.
    azurerm_resource_group.temp_resource_group_1: Importing... [id=/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/temp_rg1]
    azurerm_resource_group.temp_resource_group_1: Import complete [id=/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/temp_rg1]
    azurerm_resource_group.temp_resource_group_1: Modifying... [id=/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/temp_rg1]
    azurerm_resource_group.temp_resource_group_1: Modifications complete after 1s [id=/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/temp_rg1]
    
    Apply complete! Resources: 1 imported, 0 added, 1 changed, 0 destroyed.
    ```

4. Run apply again to ensure there are no changes.

    ```powershell
    terraform apply -auto-approve
    ```

    ```bash
    terraform apply -auto-approve
    ```

5. Remove the `import` block and apply again.

    Delete the `import` block from `main.tf` and run an apply.

    ```powershell
    terraform apply -auto-approve
    ```

    ```bash
    terraform apply -auto-approve
    ```

### 4. Check state

Run a `terraform show`. The "temp_rg" resource group should now appear in the output as well.

```powershell
terraform show
```

```bash
terraform show
```

### 5. Remove the resource block

1. Remove the `resource` and `data` block we added for `temp_resource_group_1` from `main.tf`

    `main.tf` should just look just like below. (as it was before we started this lab)

    ```terraform
    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
      }
    }
    
    provider "azurerm" {
      features {}
    }
    
    locals {
      subnets = cidrsubnets("10.0.0.0/24", 6, 7, 8)
    }
    
    resource "azurerm_resource_group" "demo" {
      for_each = var.resource_groups
      name     = "${var.prefix}_${each.value}"
      location = var.region
      tags     = var.tags
    }
    ```

### 6. Plan and apply

1. Run a plan and apply to delete `temp_rg1`

  ```powershell
  terraform apply
  ```

  ```bash
  terraform apply
  ```

1. Check the plan is showing it will destroy `temp_rg1`

  ```text
  Terraform will perform the following actions:
  
    # azurerm_resource_group.temp_resource_group_1 will be destroyed
    # (because azurerm_resource_group.temp_resource_group_1 is not in configuration)
    - resource "azurerm_resource_group" "temp_resource_group_1" {
        - id         = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/temp_rg1" -> null
        - location   = "uksouth" -> null
        - name       = "temp_rg1" -> null
        - tags       = {
            - "reference" = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/temp_rg2"
          } -> null
          # (1 unchanged attribute hidden)
      }
  
  Plan: 0 to add, 0 to change, 1 to destroy.
  ```

1. Enter `yes` to run thye apply

### 7. Verify that temp_rg is deleted

1. Check the portal or cli to ensure `temp_rg1` is deleted.
1. Run a `terraform show` to ensure it's gone from state file as well.

---
