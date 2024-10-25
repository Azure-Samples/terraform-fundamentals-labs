---
layout: page
title: Terraform expressions and functions
description: Lab 3 - Part 1 - Expressions
---

## Lab description

In this lab we learn about `expressions` in Terraform.

## Expressions

### Setup

Make sure you are in the correct folder:

```powershell
cd ~/terraform-labs
```

```bash
cd ~/terraform-labs
```

If you were unable to complete the last lab, you can find a copy of the files in the [solutions folder]({{ site.github.repository_url }}/tree/main/docs/02-terraform-configuration/solutions/03)

### 1. Create a variable of type `list`, so we can pass in a list of resource group names

1. In `variables.tf`, add a new variable called `resource_group_names`, so it looks like below.  

    ```terraform
    variable resource_groups {
      type        = map(string)
      description = "The resource groups to deploy"
    }
    
    variable "prefix" {
      type        = string
      description = "A prefix for all resources"
      default     = "contoso"
    }
    
    variable "region" {
      type        = string
      default     = "North Europe"
      description = "The Azure region to deploy resources"
      validation {
        condition     = contains(["UK South", "UK West", "North Europe", "West Europe", "East US", "West US"], var.region)
        error_message = "Invalid region"
      }
    }
    
    variable "tags" {
      type        = map(any)
      description = "A map of tags"
    }
    ```

2. Pass the values for resource group names in `terraform.tfvars`.

    ```terraform
    resource_groups = {
      dev     = "research_dev_rg"
      staging = "research_staging_rg"
      prod    = "research_prod_rg"
    }
    
    tags = {  
      cost_center = "contoso research"    
    } 
    ```

3. Remove duplicate code from `main.tf`, so it now looks like below

    > Take a few minutes to observe the usage of for_each here.

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
    
    resource "azurerm_resource_group" "demo" {
      for_each = var.resource_groups
      name     = "${var.prefix}_${each.value}"
      location = var.region
      tags     = var.tags
    }
    ```

4. Finally, modify `outputs.tf` as below, so it can print out all of the resource group ids.

    > NOTE: We are using a for expression here.

    ```terraform
    output "resource_group_ids" {
      value       = { for key, value in azurerm_resource_group.demo : key => value.id }
      description = "Resource group ids"
    }
    ```

### 2. Plan

1. Run `terraform destroy -auto-approve` to clean up any existing resources.

    > NOTE: Even though we have updated the code, Terraform knows about our existing resources and will clean them up because of the state file.

1. Run a `plan` and take a moment to understand how the changes will be applied.

    * Feel free to pass in `contoso.<region>.tfvars` if needed.
    * By default, we deploy to `UK South` (as defined in `terraform.tfvars`)

1. It should look something like below:

    ```text
    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:        
      + create
    
    Terraform will perform the following actions:
    
      # azurerm_resource_group.demo["dev"] will be created
      + resource "azurerm_resource_group" "demo" {
          + id       = (known after apply)
          + location = "northeurope"
          + name     = "contoso_research_dev_rg"
          + tags     = {
              + "cost_center" = "contoso research"
            }
        }
    
      # azurerm_resource_group.demo["prod"] will be created
      + resource "azurerm_resource_group" "demo" {
          + id       = (known after apply)
          + location = "northeurope"
          + name     = "contoso_research_prod_rg"
          + tags     = {
              + "cost_center" = "contoso research"
            }
        }
    
      # azurerm_resource_group.demo["staging"] will be created
      + resource "azurerm_resource_group" "demo" {
          + id       = (known after apply)
          + location = "northeurope"
          + name     = "contoso_research_staging_rg"
          + tags     = {
              + "cost_center" = "contoso research"
            }
        }
    
    Plan: 3 to add, 0 to change, 0 to destroy.
    
    Changes to Outputs:
      + resource_group_ids = {
          + dev     = (known after apply)
          + prod    = (known after apply)
          + staging = (known after apply)
        }
    ```

### 3. Apply

When ready, run a `terraform apply`

### 4. Verify

1. Verify the output and resources on Azure portal (or cli)

    The output should look something like below.

    ```text
    Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
    
    Outputs:
    
    resource_group_ids = {
      "dev" = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_dev_rg"
      "prod" = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_prod_rg"
      "staging" = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_staging_rg"
    }
    ```

### 5. Commit your code

1. `git add` and `commit` as we've done before.

### 6. Recap

Take a few minutes to have glance through the different topics we've covered here under expressions.

* <https://developer.hashicorp.com/terraform/language/expressions>

---

[Next Lab - Functions](02-functions.md)
