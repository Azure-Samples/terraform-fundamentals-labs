---
layout: page
title: Terraform configuration
description: Lab 2 - Part 2 - Variables
---

## Lab description

In this lab we learn about the `variable` definition in Terraform.

## Variables

### Setup

Make sure you are in the correct folder:

```powershell
cd ~/terraform-labs
```

```bash
cd ~/terraform-labs
```

If you were unable to complete the last lab, you can find a copy of the files in the [solutions folder]({{ site.github.repository_url }}/tree/main/docs/02-terraform-configuration/solutions/01)

### 1. Refactor `main.tf` to make it more configurable using variables

Introduce variables to `main.tf`

Notice how each variable has a slightly different setup. We've done this, so we can try different approaches to pass in data:

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

variable "prefix" {}

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

resource "azurerm_resource_group" "contoso_rg" {
  name     = "${var.prefix}_rg"
  location = var.region
  tags     = var.tags
}

resource "azurerm_resource_group" "contoso_dev_rg" {
  name     = "${var.prefix}_dev_rg"
  location = var.region
  tags     = var.tags
}
```

### 2. terraform.tfvars

1. Create a file called `terraform.tfvars`.

    ```powershell
    cd ~/terraform-labs
    code terraform.tfvars
    ```

    ```bash
    cd ~/terraform-labs
    code terraform.tfvars
    ```

2. Add tag inputs to `terraform.tfvars` so it looks like below.

    ```terraform
    # terraform.tfvars
    tags = {  
      cost_center = "contoso research"    
    }
    ```

### 3. Plan and Apply

1. Now, run a `terraform plan`. When prompted for `var.prefix`, enter `contoso`:

    * You should something like below, stating that there will be a force replacement.
    * This is because, now our default region is set to "North Europe" and we are not passing any overrides.
    * We are prompted for `prefix` because we haven't set any `default` value

    ```text
    azurerm_resource_group.contoso_dev_rg: Refreshing state... [id=/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_dev_rg]
    azurerm_resource_group.contoso_rg: Refreshing state... [id=/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_rg]
    
    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
    -/+ destroy and then create replacement
    
    Terraform will perform the following actions:
    
      # azurerm_resource_group.contoso_dev_rg must be replaced
    -/+ resource "azurerm_resource_group" "contoso_dev_rg" {
          ~ id         = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_dev_rg" -> (known after apply)
          ~ location   = "uksouth" -> "northeurope" # forces replacement
            name       = "contoso_dev_rg"
            tags       = {
                "cost_center" = "contoso research"
            }
            # (1 unchanged attribute hidden)
        }
    
      # azurerm_resource_group.contoso_rg must be replaced
    -/+ resource "azurerm_resource_group" "contoso_rg" {
          ~ id         = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_rg" -> (known after apply)
          ~ location   = "uksouth" -> "northeurope" # forces replacement
            name       = "contoso_rg"
            tags       = {
                "cost_center" = "contoso research"
            }
            # (1 unchanged attribute hidden)
        }
    
    Plan: 2 to add, 0 to change, 2 to destroy.
    ```

2. When ready, do a `terraform apply` and enter `contoso` when prompted for prefix. (_and then enter `yes` when asked for approval_).

### 4. Verify the updates and commit your code

This time when doing a `git add .`, you will also see `terraform.tfvars` being added.

### 5. Environment Variables and custom .tfvars

1. We are currently passing in the `prefix` manually from cli. Let's set an `environment variable`, so it get's picked from there.

    ```powershell
    $env:TF_VAR_prefix="contoso"
    Write-Host $env:TF_VAR_prefix
    ```

    ```bash
    export TF_VAR_prefix="contoso"
    echo $TF_VAR_prefix
    ```

2. Now create two new files for .tfvars such as below, so we can make the region configurable. (this could  also be something like `.dev.tfvars`, `.prod.tfvars` in real world scenarios)

    * contoso.uk.tfvars
    * contoso.europe.tfvars

    ```powershell
    cd ~/terraform-labs
    Set-Content -Value "region = `"UK South`"" -Path "contoso.uk.tfvars"
    Set-Content -Value "region = `"North Europe`"" -Path "contoso.europe.tfvars"
    ```

    ```bash
    cd ~/erraform-labs
    echo 'region = "UK South"' > contoso.uk.tfvars
    echo 'region = "North Europe"' > contoso.europe.tfvars
    ```

    Take a quick look at both `.tfvars` files and make sure they have the correct region value.

### 6. Plan and Apply

1. Run a plan and apply using `contoso.uk.tfvars` file

    ```powershell
    terraform plan -var-file="contoso.uk.tfvars"
    terraform apply -auto-approve -var-file="contoso.uk.tfvars"
    ```

    ```bash
    terraform plan -var-file="contoso.uk.tfvars"
    terraform apply -auto-approve -var-file="contoso.uk.tfvars"
    ```

2. Notice that we are no longer prompted for `prefix` value. Terraform now picks this up from the environment variable we created.

### 7. Verify and commit

1. Verify that the resource groups are re-created in `UK South`.
2. Commit your code. This time when doing a `git add .`, you will also see two new `.tfvars` being added.

### 8. Variables.tf

In this step, we will move all the variable definitions to a separate file, so our config file (main.tf) looks tidy.

1. Create a `variables.tf` file

    ```powershell
    cd ~/terraform-labs
    code variables.tf
    ```

    ```bash
    cd ~/terraform-labs
    code variables.tf
    ```

2. Move all the variable definitions to this file, so it looks like below.

    ```terraform
    variable "prefix" {}
    
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

### 9. Plan and Apply

Run a `terraform plan and apply`, but this time pass in the other `.tfvars` file (contoso.europe.tfvars), so we can force a replacement.

```bash
terraform plan -var-file="contoso.europe.tfvars"
terraform apply -auto-approve -var-file="contoso.europe.tfvars"
```

### 10. Verify results and Commit your code

1. Verify that the resource groups are re-created in `North Europe`.
1. Commit your code to git.

### 11. Recap

Take a few minutes to observe and recap on different value sources that are used for our variables.

Your folder should look like below. Make sure you are fully comfortable with what those files are.

```text
📂terraform-labs
┣ 📂.terraform
┣ 📜.gitignore
┣ 📜.terraform.lock.hcl
┣ 📜contoso.europe.tfvars
┣ 📜contoso.tfplan
┣ 📜contoso.uk.tfvars
┣ 📜main.tf
┣ 📜terraform.tfstate
┣ 📜terraform.tfstate.backup
┣ 📜terraform.tfvars
┗ 📜variables.tf
```

### 12. Topics covered

* <https://developer.hashicorp.com/terraform/language/values/variables>
* <https://developer.hashicorp.com/terraform/cli/config/environment-variables>

---

[Next Lab - Outputs](03-outputs.md)
