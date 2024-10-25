---
layout: page
title: Terraform core workflow
description: Lab 1 - Part 2 - Day 2 Operations - write, plan and apply
---

## Lab description

This lab will cover the very basic terraform workflow for the updating of resources in Azure.

The terraform Core Workflow is still:

* Write
* Init (not needed this time)
* Plan
* Apply

## Day 2 operation (update)

### Setup

Make sure you are in the correct folder:

```powershell
cd ~/terraform-labs
```

```bash
cd ~/terraform-labs
```

If you were unable to complete the last lab, you can find a copy of the files in the [solutions folder]({{ site.github.repository_url }}/tree/main/docs/01-core-terraform-workflow/solutions/01)

### 1. Write

1. Open `main.tf` on the editor and add a `tag` by making the below change within `contoso_rg` resource

    ```terraform
    tags = {
      cost_center = "contoso research"
    }
    ```

    It should look something like below:

    ```terraform
    resource "azurerm_resource_group" "contoso_rg" {
      name     = "contoso_rg"
      location = "UK South"
    
      tags = {
        cost_center = "contoso research"
      } 
    }
    ```

1. Save `main.tf`

> Note: we are not doing an `init` this time because the `.terraform` folder and `azure provider` plugin is already available from our previous run. When running in a `CI / CD` pipeline, this step may be required.

### 2. Plan

1. Do a `terraform plan` but this time we are also storing the **`output`** in a separate `.tfplan` file

    ```powershell
    terraform plan -out contoso.tfplan
    ```

    ```bash
    terraform plan -out contoso.tfplan
    ```

1. Take a look at the plan file that's been created using **`show`** command as before.

    ```powershell
    terraform show contoso.tfplan
    ```

    ```bash
    terraform show contoso.tfplan
    ```

    You should see something like below

    ```text
    azurerm_resource_group.contoso_rg: Refreshing state... [id=/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_rg]
    
    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
      ~ update in-place
    
    Terraform will perform the following actions:
    
      # azurerm_resource_group.contoso_rg will be updated in-place
      ~ resource "azurerm_resource_group" "contoso_rg" {
            id         = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_rg"
            name       = "contoso_rg"
          ~ tags       = {
              + "cost_center" = "contoso research"
            }
            # (2 unchanged attributes hidden)
        }
    
    Plan: 0 to add, 1 to change, 0 to destroy.
    
    ───────────────────────────────────────────────────────────────────────
    
    Saved the plan to: contoso.tfplan
    
    To perform exactly these actions, run the following command to apply:
        terraform apply "contoso.tfplan"
    ```

1. Add to `.gitignore` file

    Much like, .tfstate, .tfplan files can also contain sensitive information and should be kept as secure as possible. It is also in `.gitignore` of this repo.

    ```powershell
    Add-Content .gitignore "$([Environment]::NewLine)contoso.tfplan"
    ```

    ```bash
    echo "contoso.tfplan" >> .gitignore
    ```

    > See: <https://developer.hashicorp.com/terraform/cli/commands/plan#out-filename>

### 3. Apply

Pass the plan file to terraform apply and this time, we also do an `-auto-approve`, so we are not prompted for approval.

```powershell
terraform apply -auto-approve "contoso.tfplan"
```

```bash
terraform apply -auto-approve "contoso.tfplan"
```

The terminal output should state something like below

```text
azurerm_resource_group.contoso_rg: Modifying... [id=/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_rg]
azurerm_resource_group.contoso_rg: Modifications complete after 1s [id=/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_rg]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

### 4. Verify

Verify that `cost_center` tag has been created on our resource group.

```powershell
az group show --name "contoso_rg"
```

```bash
az group show --name "contoso_rg"
```

Take a quick look at the state file as well.

```bash
terraform show terraform.tfstate
```

### 5. Version control your code

1. Add `main.tf` to git

    ```powershell
    cd ~/terraform-labs
    
    git add .
    git commit -m "Added tags to resource group"
    ```

    ```bash
    cd ~/terraform-labs
    
    git add .
    git commit -m "Added tags to resource group"
    ```

2. You are welcome to push your changes to your own remote if you prefer.

---

[Next Lab - Day n Operations](03-day-n-operations.md)
