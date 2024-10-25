---
layout: page
title: Modules
description: Lab 6 - Part 1 - Local Modules
---

## Lab description

In this lab we learn about local Terraform modules and how to create them.

## Create a local module that encapsulates what we've created so far

### Setup

Make sure you are in the correct folder:

```powershell
cd ~/terraform-labs
```

```bash
cd ~/terraform-labs
```

If you were unable to complete the last lab, you can find a copy of the files in the [solutions folder]({{ site.github.repository_url }}/tree/main/docs/05-dependencies/solutions/01)

### 1. Setup Module structure

Here, we will create a simple module called `demo` that will create a resource groups and virtual networks in new subscription.

1. To get started, create a folder called `modules` and create the required config files as below.

    ```powershell
    cd ~/terraform-labs
    New-Item -Path "./modules/demo" -ItemType Directory
    
    cd modules/demo
    New-Item -Path "./README.md" -ItemType File
    New-Item -Path "./main.tf" -ItemType File
    New-Item -Path "./outputs.tf" -ItemType File
    New-Item -Path "./variables.tf" -ItemType File
    cd ~/terraform-labs
    ```

    ```bash
    cd ~/terraform-labs
    mkdir -m modules/demo
    
    cd modules/demo
    touch README.md
    touch main.tf
    touch outputs.tf
    touch variables.tf
    cd ~/terraform-labs
    ```

1. Your file structure should now look like this:

    ```text
    📂terraform-labs
    ┣ 📂.terraform
    ┣ 📂modules
    ┃ ┗ 📂demo
    ┃   ┣ 📜main.tf
    ┃   ┣ 📜outputs.tf
    ┃   ┣ 📜README.md
    ┃   ┗ 📜variables.tf
    ┣ 📜.gitignore
    ┣ 📜.terraform.lock.hcl
    ┣ 📜contoso.europe.tfvars
    ┣ 📜contoso.tfplan
    ┣ 📜contoso.uk.tfvars
    ┣ 📜main.tf
    ┣ 📜outputs.tf
    ┣ 📜terraform.tfstate
    ┣ 📜terraform.tfstate.backup
    ┣ 📜terraform.tfvars
    ┗ 📜variables.tf
    ```

### 2. Move the resource blocks into our new module

1. Move the locals and resource blocks from `main.tf` in your root module folder into `main.tf` in `demo` module folder.

    The `demo` `main.tf` should look like this:

    ```terraform
    locals {
      subnets = { for subnet in flatten([
        for virtual_network_key, virtual_network_value in var.virtual_networks : [
          for subnet_key, subnet_value in virtual_network_value.subnets : {
            composite_key        = "${virtual_network_key}-${subnet_key}"
            name                 = subnet_value.name == null ? "${virtual_network_value.name}-${subnet_key}" : subnet_value.name
            address_prefix       = subnet_value.address_prefix
            resource_group_name  = azurerm_resource_group.demo[virtual_network_value.resource_group_key].name
            virtual_network_name = azurerm_virtual_network.demo[virtual_network_key].name
          }
        ]
      ]) : subnet.composite_key => subnet }
    }
    
    resource "azurerm_resource_group" "demo" {
      for_each = var.resource_groups
      name     = "${var.prefix}_${each.value}"
      location = var.region
      tags     = var.tags
    }
    
    resource "azurerm_virtual_network" "demo" {
      for_each            = var.virtual_networks
      name                = each.value.name
      address_space       = each.value.address_space
      location            = var.region
      resource_group_name = azurerm_resource_group.demo[each.value.resource_group_key].name
    }
    
    resource "azurerm_subnet" "demo" {
      for_each             = local.subnets
      name                 = each.value.name
      resource_group_name  = each.value.resource_group_name
      virtual_network_name = each.value.virtual_network_name
      address_prefixes     = [each.value.address_prefix]
    }
    ```

1. Copy the variables to `variable.tf`

  The `demo` `variable.tf` should look like this:

  ```terraform
  variable "resource_groups" {
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
  
  variable "virtual_networks" {
    type = map(object({
      name               = string
      resource_group_key = string
      address_space      = list(string)
      subnets = map(object({
        name           = optional(string)
        address_prefix = string
      }))
    }))
    description = "The virtual networks to deploy"
  }
  ```

1. Copy the outputs to `outputs.tf`

  The `demo` `outputs.tf` should look like this:

  ```terraform
  output "resource_group_ids" {
    value       = { for key, value in azurerm_resource_group.demo : key => value.id }
    description = "Resource group ids"
  }
  ```

1. Call the module from the root `main.tf`

  The `main.tf` in the root module should look like this:

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
  
  module "demo" {
    source = "./modules/demo"
    
    prefix = var.prefix
    region = var.region
    resource_groups = var.resource_groups
    virtual_networks = var.virtual_networks
    tags = var.tags
  }
  ```

1. Update `outputs.tf` to reference the module

    The `outputs.tf` in the root module should look like this:

    ```terraform
    output "resource_group_ids" {
      value       = module.demo.resource_group_ids
      description = "Resource group ids"
    }
    ```

### 3. Plan

1. When you're ready, run a plan. Make sure you're in the correct folder.

    ```powershell
    cd ~/terraform-labs
    terraform plan
    ```

    ```bash
    cd ~/terraform-labs
    terraform plan
    ```

1. This will fail as we need to `initialize` our new module

    ```text
    │ Error: Module not installed
    │
    │   on main.tf line 14:
    │   14: module "demo" {
    │
    │ This module is not yet installed. Run "terraform init" to install all modules required by this configuration.
    ```

1. Run an Init

```powershell
terraform init
```

```bash
terraform init
```

1. Run a plan. You should see an output similar to below

    You will see a plan that will destroy and re-create all the resources. This is because we are moving the resources to a module and terraform sees them as new resources.

    > NOTE: We can use the `moved` block to move resources to a module without destroying them.

1. Add `moved` blocks

    Add the following blocks to `main.tf` in the root module.

    ```terraform
    moved {
      from = azurerm_resource_group.demo
      to   = module.demo.azurerm_resource_group.demo
    }
    
    moved {
      from = azurerm_virtual_network.demo
      to   = module.demo.azurerm_virtual_network.demo
    }
    
    moved {
      from = azurerm_subnet.demo
      to   = module.demo.azurerm_subnet.demo
    }
    ```

1. Run the plan again

    ```powershell
    terraform plan
    ```

    ```bash
    terraform plan
    ```

    You should see an output similar to below. This time it will not plan to destroy and re-create the resources.

    ```text
    Terraform will perform the following actions:

      # azurerm_resource_group.demo["dev"] has moved to module.demo.azurerm_resource_group.demo["dev"]
        resource "azurerm_resource_group" "demo" {
            id         = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_dev_rg"
            name       = "contoso_research_dev_rg"
            tags       = {
                "cost_center" = "contoso research"
            }
            # (2 unchanged attributes hidden)
        }
    
      # azurerm_resource_group.demo["prod"] has moved to module.demo.azurerm_resource_group.demo["prod"]
        resource "azurerm_resource_group" "demo" {
            id         = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_prod_rg"
            name       = "contoso_research_prod_rg"
            tags       = {
                "cost_center" = "contoso research"
            }
            # (2 unchanged attributes hidden)
        }
    
      # azurerm_resource_group.demo["staging"] has moved to module.demo.azurerm_resource_group.demo["staging"]
        resource "azurerm_resource_group" "demo" {
            id         = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_staging_rg"
            name       = "contoso_research_staging_rg"
            tags       = {
                "cost_center" = "contoso research"
            }
            # (2 unchanged attributes hidden)
        }
    
      # azurerm_subnet.demo["dev-subnet1"] has moved to module.demo.azurerm_subnet.demo["dev-subnet1"]
        resource "azurerm_subnet" "demo" {
            id                                            = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_dev_rg/providers/Microsoft.Network/virtualNetworks/vnet-dev/subnets/subnet-dev-1"
            name                                          = "subnet-dev-1"
            # (8 unchanged attributes hidden)
        }
    
      # azurerm_subnet.demo["prod-subnet1"] has moved to module.demo.azurerm_subnet.demo["prod-subnet1"]
        resource "azurerm_subnet" "demo" {
            id                                            = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_prod_rg/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/vnet-prod-subnet1"
            name                                          = "vnet-prod-subnet1"
            # (8 unchanged attributes hidden)
        }
    
      # azurerm_subnet.demo["prod-subnet2"] has moved to module.demo.azurerm_subnet.demo["prod-subnet2"]
        resource "azurerm_subnet" "demo" {
            id                                            = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_prod_rg/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/vnet-prod-subnet2"
            name                                          = "vnet-prod-subnet2"
            # (8 unchanged attributes hidden)
        }
    
      # azurerm_subnet.demo["staging-subnet1"] has moved to module.demo.azurerm_subnet.demo["staging-subnet1"]
        resource "azurerm_subnet" "demo" {
            id                                            = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_staging_rg/providers/Microsoft.Network/virtualNetworks/vnet-staging/subnets/subnet-staging-1"
            name                                          = "subnet-staging-1"
            # (8 unchanged attributes hidden)
        }
    
      # azurerm_virtual_network.demo["dev"] has moved to module.demo.azurerm_virtual_network.demo["dev"]
        resource "azurerm_virtual_network" "demo" {
            id                      = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_dev_rg/providers/Microsoft.Network/virtualNetworks/vnet-dev"
            name                    = "vnet-dev"
            tags                    = {}
            # (9 unchanged attributes hidden)
        }
    
      # azurerm_virtual_network.demo["prod"] has moved to module.demo.azurerm_virtual_network.demo["prod"]
        resource "azurerm_virtual_network" "demo" {
            id                      = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_prod_rg/providers/Microsoft.Network/virtualNetworks/vnet-prod"
            name                    = "vnet-prod"
            tags                    = {}
            # (9 unchanged attributes hidden)
        }
    
      # azurerm_virtual_network.demo["staging"] has moved to module.demo.azurerm_virtual_network.demo["staging"]
        resource "azurerm_virtual_network" "demo" {
            id                      = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_staging_rg/providers/Microsoft.Network/virtualNetworks/vnet-staging"
            name                    = "vnet-staging"
            tags                    = {}
            # (9 unchanged attributes hidden)
        }
    
    Plan: 0 to add, 0 to change, 0 to destroy.
    ```

### 4. Apply

1. When ready, perform an apply. You should receive an output such as below.

    ```text
    Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
    
    Outputs:
    
    resource_group_ids = {
      "dev" = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_dev_rg"
      "prod" = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_prod_rg"
      "staging" = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_research_staging_rg"
    }
    ```

### 5. Verify

As done before, verify the changes. Pay close attended to the moved resources in state.

### 6. Commit the changes to git

1. Add the new files to git.

    ```powershell
    git add .
    git commit -m "Added local module"
    ```

    ```bash
    git add .
    git commit -m "Added local module"
    ```

### 7. Recap

See more: <https://developer.hashicorp.com/terraform/language/modules/develop>

We've covered a handful of core terraform concepts thus far. Take your time to familiarize yourself with the topics we've covered so far and feel free to repeat the labs as needed.

Also take a look at commands such as `fmt`

* `fmt` will format the config according to style guide. <https://developer.hashicorp.com/terraform/cli/commands/fmt>

---
