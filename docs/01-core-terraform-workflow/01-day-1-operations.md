---
layout: page
---

# Understand the terraform core workflow. (write, plan, apply) - Day 1 Operations

[Back to Lab Index](../README.md)

This lab will cover the very basic terraform workflow for the inital creation of resources in Azure.

## Terraform Core Workflow

* Write
* Plan
* Apply

## Setup

> Make sure you are in the correct folder

```powershell

```

```bash
# if you are using azure shell
cd ~/clouddrive/tfw/contoso

# Navigate accordingly if you are using your own dev environment
```

## Day 1 operation (Create)

> NOTE: For the following commands you'll need to be authenticated to Azure and connected to the subscription you want to deploy to. HINT: Use `az login` and `az account set --subscription mysubscription`

### 1. Write

1. Open `main.tf` on the editor and paste in the below code.

    > If you are in `cloud shell`, you can type **`code .`** and select `main.tf` or simply **`code main.tf`** in terminal to bring up the editor.
  
    ```terraform
    # Specifiy the provider and version
    terraform {
        required_providers {
            azurerm = {
                source  = "hashicorp/azurerm"
                version = "~>3.34.0"
            }
        }
    }
    
    # Configure the Microsoft Azure Provider
    provider "azurerm" {
        features {}
    }
    
    # Create the very first resource
    resource "azurerm_resource_group" "contoso_rg" {
        name = "contoso_rg"
        location = "UK South"
    }
    ```

1. Take a quick look at above code and understand what it does.
1. Save `main.tf` (`ctrl + s` should work on cloud shell)

### 2. Init

1. From terminal, (shortcut `ctrl + '` on cloud shell or vs code)

    ```powershell
    terraform init
    ```

    ```bash
    terraform init
    ```

    Take a look at what's been created

1. `.terraform.lock.hcl` - Lock file to record the provider selections it made above.

    ```powershell
    dir
    ```

    ```bash
    ls -a
    ```

    To upgrade to newer version of the provider in the future, will require a **`terraform init --upgrade`**, which will then also update the lock file. This prevents accidental version bump following a change to `main.tf`.

    Ensure `.terraform.lock.hcl` is version controlled.

1. `.terraform` directory - Contains provider itself that got installed based on the version specified in `main.tf`.

    ```powershell
    
    ```

    ```bash
    ls -R ./.terraform/providers/*/   

    # Above should display something like "terraform-provider-azurerm_v2.x.0_x5"
    ```

### 3. Plan

```bash
# plan. Below command will generate an execution plan.
# Take a few minutes to go through the terminal output and see what changes will be applied

terraform plan
```  

You should see something like below

```bash
▶ terraform plan           

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.contoso_rg will be created
  + resource "azurerm_resource_group" "contoso_rg" {
      + id       = (known after apply)
      + location = "uksouth"
      + name     = "contoso_rg"
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

### 4. Apply

```bash
# apply
terraform apply
```

> When prompted to enter a value, type **`yes`** to approve

The terminal output should say something like below

```bash
azurerm_resource_group.contoso_rg: Creating...

azurerm_resource_group.contoso_rg: Creation complete after 1s [id=/subscriptions/.../resourceGroups/contoso_rg]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

> Note that `terraform.tfstate` file has been created locally upon our first apply. State management is a topic on its own and we'll cover it separately. 

### 5. Verify

Verify that the resource has been created, either via `Azure Portal` or using `az cli` and `jq` on `cloudshell`

```bash
# On CloudShell,
az group list | jq '.[].name | select(contains("contoso"))'

# or
az group list | jq '.[] | select(.name == "contoso_rg")'
```

* Take a few minutes to understand what `terraform` generated during `apply`

```bash
# Below should display the current state of your terraform managed infrastructure    
terraform show 

#or specifiy the state file name explicitly
terraform show terraform.tfstate
```

The terraform `show` command is used to provide human-readable output from a state or plan file. See: https://www.terraform.io/docs/commands/show.html

> **Important Note**:
Besides information about terrafform-managed-resources, `tfstate` will often contain sensitive information and therefore must be kept be very secure. You will see that it's in `.gitignore` to make sure it's not accidentally checked into version control. We'll cover more on State Management later.

---

### 6. Version control your code

1. Add `main.tf` and `.terraform.hcl.lock` to git

1. Below will only include `main.tf` because all other items such as `terraform.tfstate`, `.terraform` are in `.gitgnore`. 

    ```bash
    # Make sure you're in right folder
    cd ~/clouddrive/tfw/contoso
    
    # add
    git add .
    # Commit
    git commit -m "created resource group"

    # or 
    # just one line
    git commit -am "created resource group"
    ```

1. You are welcome to push your changes to your own github remote if you prefer. 

    * For this, You'll have to setup an ssh key using `ssh-keygen` from your cloud shell and add the public key to your github account in order to be able push the repo to your origin.

    * You'll also have up your `remote` by doing a `git remote add <your_remote_origin_name(e.g: upstream)> <your_remote_url>

    * See: https://help.github.com/en/github/using-git/adding-a-remote

    * If you're new to git, and unsure about these steps. Feel free to skip for now, and we can cover these tomorrow when discussing Terraform and DevOps.

---

[Next Lab - Day 2 Operations](02-day-2-operations.md)

[Back to Lab Index](../README.md)
