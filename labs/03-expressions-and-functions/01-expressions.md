## Let's use some expressions on our config

#### Setup

> Make sure you are in the correct folder

```bash
cd ~/clouddrive/tfw/contoso
```

> Make sure you have cleaned up your infrastructure from previous lab. Or else, do a `terraform destroy`

#### Let's make below changes to our config and remove some duplicate code

#### 1. Create a variable of type `list`, so we can pass in a list of resource group names

In **variables.tf**, add a new variable called `rg_names`, so it looks like below.  

Optionally, set a default value to prefix as well.

```terraform
# variables.tf
variable rg_names {
    type = list(string)    
}

variable prefix {
    type = string
    default = "contoso"
}

variable region {           
    type = string
    default = "UK South"
}

variable tags {
    type = map          
}
```

#### 2. Pass the values for resource group names in `terraform.tfvars`, so it now looks like below

```terraform
# terraform.tfvars
rg_names = [
    "research_dev_rg",
    "research_staging_rg",
    "research_prod_rg"
]

tags = {  
    cost_center = "contoso research"    
} 
```

#### 3. Remove duplicate code from main.tf, so it now looks like below.

> Take a few minnutes to observe the usage of count and list indexing here.

> length(type) is a built-in function. We'll cover functions in following lab. 


_To become familar HCL syntax, please take your time to type in the code whenever possible._

```terraform
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

#### 4. Finally, modify `outputs.tf` as below, so it can print out all of the resource group ids.

```terraform
# outputs.tf
output "rg_ids" {    
    # splatting expression
    value = azurerm_resource_group.rgs.*.id   
    # or for expression
    # value = [for rg in azurerm_resource_group.rgs : rg.id]     
}
```

#### Plan

* Run a `plan` and take a moment to understand how the changes will be applied. 

    * Feel free to pass in `contoso.<region>.tfvars` if needed. 
    * By default, we deploy to `UK South` (as defined in `terraform.tfvars`))

* It should look something like below

```bash
Terraform will perform the following actions:

  # azurerm_resource_group.rgs[0] will be created
  + resource "azurerm_resource_group" "rgs" {
      + id       = (known after apply)
      + location = "uksouth"
      + name     = "contoso_research_dev_rg"
      + tags     = {
          + "cost_center" = "contoso research"
        }
    }

  # azurerm_resource_group.rgs[1] will be created
  + resource "azurerm_resource_group" "rgs" {
      + id       = (known after apply)
      + location = "uksouth"
      + name     = "contoso_research_staging_rg"
      + tags     = {
          + "cost_center" = "contoso research"
        }
    }

  # azurerm_resource_group.rgs[2] will be created
  + resource "azurerm_resource_group" "rgs" {
      + id       = (known after apply)
      + location = "uksouth"
      + name     = "contoso_research_prod_rg"
      + tags     = {
          + "cost_center" = "contoso research"
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.

```

#### apply

When ready, run a `terraform apply`

* Press `yes` when prompted or do an `-auto-approve` as done previously.

#### Verify

Verify the output and resources on Azure portal (or cli)

The output should look something like below.

```
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

rg_ids = [
  "/subscriptions/.../resourceGroups/contoso_research_dev_rg",
  "/subscriptions/.../resourceGroups/contoso_research_staging_rg",
  "/subscriptions/.../resourceGroups/contoso_research_prod_rg",
]
```

#### Clean up your Infrastructure

* Run a `terraform destroy`

#### Commit your code
* Do a `git add` and `commit` as we've done before.

---

#### Recap:

Take a few minutes to have glance through the different topics we've covered here under expressions.

> https://www.terraform.io/docs/configuration/expressions.html

When ready, proceed to next lab.
