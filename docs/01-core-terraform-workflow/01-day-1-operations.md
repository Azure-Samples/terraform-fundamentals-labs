---
layout: page
title: Terraform core workflow
description: Lab 1, Part 1 - Day 1 Operations - write, init, plan and apply
---

## Lab description

This lab will cover the very basic terraform workflow for the inital creation of resources in Azure.

The terraform Core Workflow is:

* Write
* Init
* Plan
* Apply

### Setup

Make sure you are in the correct folder:

```powershell
cd ~/terraform-labs
```

```bash
cd ~/terraform-labs
```

### Day 1 operation (Create)

For the following commands you'll need to be authenticated to Azure and connected to the subscription you want to deploy to.

> HINT: Use `az login` and `az account set --subscription mysubscription`

#### 1. Write

1. Create a file called `main.tf` and open in your editor, then paste in the below code.

    > HINT: If you are using VSCode, you can type **`code .`** and select `main.tf` or simply **`code main.tf`** in terminal to bring up the editor.
  
    ```terraform
    # Specifiy the provider and version
    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
      }
    }
    
    # Configure the Microsoft Azure Provider
    provider "azurerm" {
      features {}
    }
    
    # Create the very first resource
    resource "azurerm_resource_group" "contoso_rg" {
      name     = "contoso_rg"
      location = "UK South"
    }
    ```

1. Take a quick look at above code and understand what it does.
1. Save `main.tf` (`ctrl + s`)

> HINT: Turn on auto save in VSCode to make your life easier. Go to `File` > `Auto Save` or `ctrl + shift + p` and type `Auto Save` and select `Toggle Auto Save`.

#### 2. Init

1. From terminal, (shortcut `ctrl + '` in vs code)

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

    You can version control `.terraform.lock.hcl` to ensure everyone gets the same versions moving forward.

1. `.terraform` directory - Contains provider itself that got installed based on the version specified in `main.tf`.

    ```powershell
    ls -R ./.terraform/providers/*/
    ```

    Above should display something like `terraform-provider-azurerm_v4.7.0_x5.exe`.

    ```bash
    ls -R ./.terraform/providers/*/   
    ```

    Above should display something like `terraform-provider-azurerm_v4.7.0_x5`.

#### 3. Plan

Starting with AzureRM 4.0, the subscription ID is required. We can either hard code it into our provider block or use the `ARM_SUBSCRIPTION_ID` environment variable. We are going to use the environment variable in this lab.

> HINT: Can't remember your subscription id? Run `az account show --query id -o tsv` in your terminal.

```powershell
$env:ARM_SUBSCRIPTION_ID = "your_subscription_id"
```

```bash
export ARM_SUBSCRIPTION_ID="your_subscription_id"
```

We can now run the plan:

```powershell
terraform plan
```

```bash
terraform plan
```  

You should see something like below:

```text
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
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

#### 4. Apply

```powershell
terraform apply
```

```bash
terraform apply
```

> When prompted to enter a value, type **`yes`** to approve

The terminal output should say something like below

```text
azurerm_resource_group.contoso_rg: Creating...
azurerm_resource_group.contoso_rg: Creation complete after 9s [id=/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_rg]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

> Note that `terraform.tfstate` file has been created locally upon our first apply. State management is a topic on its own and we'll cover it separately.

#### 5. Verify

Verify that the resource has been created, either via `Azure Portal` or using `az cli`.

```powershell
az group list --query "[?name == 'contoso_rg']"
```

```bash
az group list | jq '.[] | select(.name == "contoso_rg")'
```

Take a few minutes to understand what `terraform` generated during `apply`

```powershell
terraform show 

terraform show terraform.tfstate
```

```bash
terraform show 

terraform show terraform.tfstate
```

The terraform `show` command is used to provide human-readable output from a state or plan file. See: <https://developer.hashicorp.com/terraform/cli/commands/show>

> **Important Note**:
Besides information about terraform managed resources, `tfstate` will often contain sensitive information and therefore must be kept be very secure. You will see that it's in `.gitignore` to make sure it's not accidentally checked into version control. We'll cover more on State Management later.

---

#### 6. Version control your code

1. Add a `.gitignore` file to your folder, copying the content from <https://github.com/github/gitignore/blob/main/Terraform.gitignore>.
1. Add `main.tf` and `.terraform.hcl.lock` to git

    Below will only include `main.tf` and `.terraform.hcl.lock` because all other items such as `terraform.tfstate`, `.terraform` are in `.gitgnore`.

    ```powershell
    cd ~/terraform-labs
    
    git init
    git add .
    git commit -m "created resource group"
    ```

    ```bash
    cd ~/terraform-labs
    
    git init
    git add .
    git commit -m "created resource group"
    ```

1. You are welcome to push your changes to your own github remote if you prefer.

    * For this, You'll have to setup an ssh key using `ssh-keygen` from your cloud shell and add the public key to your github account in order to be able push the repo to your origin.

    * You'll also have up your `remote` by doing a `git remote add <your_remote_origin_name(e.g: upstream)> <your_remote_url>

    * See: <https://help.github.com/en/github/using-git/adding-a-remote>

    * If you're new to git, and unsure about these steps. Feel free to skip for now, and we can cover these tomorrow when discussing Terraform and DevOps.

---

[Next Lab - Day 2 Operations](02-day-2-operations.md)
