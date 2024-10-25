---
layout: page
title: Terraform configuration
description: Lab 2 - Part 1 - Locals
---

## Lab description

In this lab we learn about `locals` in Terraform.

## Locals

### Setup

Make sure you are in the correct folder:

```powershell
cd ~/terraform-labs
```

```bash
cd ~/terraform-labs
```

If you were unable to complete the last lab, you can find a copy of the files in the [solutions folder]({{ site.github.repository_url }}/tree/main/docs/01-core-terraform-workflow/solutions/03)

### 1. Refactor main.tf to use locals

1. Make below changes to `main.tf` so we are no longer hardcoding values.

    > Please avoid `copying and pasting` unless specified. Authoring terraform config files on your own is the best way to learn terraform and understand how it works.

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
      prefix = "contoso"
      region = "UK South"
      tags = {
        cost_center = "contoso research"
      }
    }
    
    resource "azurerm_resource_group" "contoso_rg" {
      name     = "${local.prefix}_rg"
      location = local.region
      tags     = local.tags
    }
    
    resource "azurerm_resource_group" "contoso_dev_rg" {
      name     = "${local.prefix}_dev_rg"
      location = local.region
      tags     = local.tags
    }
    ```

2. Run a `plan` and `apply` as we've done before.

  ```powershell
  terraform plan -out "contoso.tfplan"
  terraform apply "contoso.tfplan" 
  ```

  ```bash
  terraform plan -out "contoso.tfplan"
  terraform apply "contoso.tfplan" 
  ```

  Your plan should add 2 resource groups.
  
  > Note: From now on, we will simply refer to these operations as `plan and apply`.

### 2. Verify

1. Verify that resources have been created correctly as we've done before. (via azure portal or cli)
2. Run a `terraform show` on the the state to ensure it's correct and as expected.

### 3. Commit your changes to git

1. Do a `git add .` and `git commit -m "added locals"` as before. Ensure that only the `main.tf` file gets added.
2. Optionally, push it your remote if you have it setup.

### 4. Topics covered

* <https://developer.hashicorp.com/terraform/language/values/locals>

---

[Next Lab - Variables](02-variables.md)
