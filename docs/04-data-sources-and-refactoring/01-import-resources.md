## Know how to import existing resources to make Terraform aware of them.

#### Setup

> Make sure you are in the correct folder

```bash
cd ~/clouddrive/tfw/contoso
```

---

#### Create a resource group called "temp_rg" using azure portal or cli in "UK South"

Create a couple of resource groups outside of terraform.

```bash
az group create --name temp_rg --location "UK South"
az group create --name temp_rg2 --location "UK South"
```

> verify that the resource group is created

Append below code into `main.tf` (we are trying to create same resource group via terraform)

We are also using `data` block, so we can retrieve the `id` of `temp_rg2` resource group

```terraform
data "azurerm_resource_group" "temp_rg2_res" {
  name = "temp_rg2"
}

resource "azurerm_resource_group" "rg" {
    name = "temp_rg"
    location = "UK South"

    tags = {
      reference = data.azurerm_resource_group.temp_rg2_res.id
    }
}
```

#### Plan

```bash
terraform plan
```

You should see something like below where terraform thinks `temp_rg` is a new resource

```bash
Terraform will perform the following actions:

  # azurerm_resource_group.rg will be created
  + resource "azurerm_resource_group" "rg" {
      + id       = (known after apply)
      + location = "uksouth"
      + name     = "temp_rg"

      + tags = {
        reference = "..../temp_rg2"
      }
    }

    # ....plus other resource groups we know of
```

> **Data Source** - Also note that we are able to refer the id of `temp_rg2` resource group without any issues. This is because we are not trying to manage that resource, but only retrieving some details about it.

---

#### Apply (and observe the error)

Run an apply, you should get an error message such as below.

```bash
terraform apply

Error: A resource with the ID "/subscriptions/.../resourceGroups/temp_rg" already exists - to be managed via Terraform this resource needs to be imported into the State. Please see the resource documentation for "azurerm_resource_group" for more information.

  on main.tf line 14, in resource "azurerm_resource_group" "rg":
  14: resource "azurerm_resource_group" "rg" {
---
```

This is because terraform wasn't aware of this resource until it tried an apply.

#### Import

Now, run the following command in the terminal.

> Replace `<subscription_id>` with your subscription id

```bash
terraform import azurerm_resource_group.rg "/subscriptions/<subscription_id>/resourceGroups/temp_rg"
```

You should see an output such as below

```bash
azurerm_resource_group.rg: Importing from ID "/subscriptions/.../resourceGroups/temp_rg"...
azurerm_resource_group.rg: Import prepared!
  Prepared azurerm_resource_group for import
azurerm_resource_group.rg: Refreshing state... [id=/subscriptions/.../resourceGroups/temp_rg]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

#### Check state

Run a `terraform show`. The "temp_rg" resource group should now appear in the output as well.

```bash
terraform show
# or
# terraform show | grep "temp_rg"
```

#### Plan
Run a `terraform plan`. This time, `temp_rg` should also get picked up such as below. This means we should be able to manage this resource using terraform moving forward.

```bash
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

azurerm_resource_group.rg: Refreshing state... [id=/subscriptions/.../resourceGroups/temp_rg]

#...other items...
```

#### Remove the resource block for `temp_rg` from main.tf

>Remove the `resource` block we added for `temp_rg` from main.tf

**or**

>just unstage the change via git. If you've committed the code from previous lab, the only change should be the addition of that resource block for temp_rg

main.tf should just look just like below. (as it was before we started this lab)
```
# main.tf
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

resource "azurerm_resource_group" "rgs" {  
    count = length(var.rg_names)
    name = "${var.prefix}_${var.rg_names[count.index]}"
    location = var.region
    tags = var.tags
}
```

#### Plan and apply

Run a plan and apply to delete `temp_rg`

```bash
terraform plan

Terraform will perform the following actions:

  # azurerm_resource_group.rg will be destroyed
  - resource "azurerm_resource_group" "rg" {
      - id       = "/subscriptions/.../resourceGroups/temp_rg" -> null
      - location = "uksouth" -> null
      - name     = "temp_rg" -> null
      - tags     = {} -> null

      - timeouts {}
    }

Plan: 0 to add, 0 to change, 1 to destroy.
```
> Run an apply when ready
```bash
terraform apply

...
Apply complete! Resources: 0 added, 0 changed, 1 destroyed.
...
```

#### Verify that temp_rg is deleted

* Check the portal or cli to ensure `temp_rg` is deleted. 
* Run a `terraform show` to ensure it's gone from state file as well.

---

#### Clean up the infrastructure with a `terraform destroy`

> There shouldn't be any pending changes to commit as we've reverted the changes made to `main.tf`







