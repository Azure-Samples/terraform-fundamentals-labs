## Locals

#### Setup

> Make sure you are in the correct folder

```bash
# if you are using azure shell

cd ~/clouddrive/tfw/contoso

# Ensure the resource groups from previous lab has been destroyed and tf state is clean
# Below should be empty
terraform show
```
---

## Refactor main.tf to use locals

* Make below changes to `main.tf` so we are no longer hardcoding values.

> Please avoid `copying and pasting` unless specified. 

> Authoring terraform config files on your own is the best way to learn terraform and understand how it works.


```terraform
locals {   
    prefix = "contoso"
    region = "UK South"
    tags = {
        cost_center = "contoso research"
    }
}

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

resource "azurerm_resource_group" "contoso_rg" {
    name = "${local.prefix}_rg"
    location = local.region
    tags = local.tags
}

resource "azurerm_resource_group" "contoso_dev_rg" {    
    name = "${local.prefix}_dev_rg"
    location = local.region
    tags = local.tags
}

```
Run a `plan` and `apply` as we've done before. 

Option 1: (via plan file)
```bash
terraform plan -out "contoso.tfplan"
terraform apply -auto-approve "contoso.tfplan" 
```

**or**

Option 2: (in memory)
```bash
terraform plan
terraform apply
```

> Note: From now on, we will simply refer to these operations as **`plan and apply`**.

> If you still have any questions about this, please feel free to ask questions on chat.

#### Verify

* Verify that resources have been created correctly as we've done before. (via azure portal or cli)

* Run a **_`terraform show`_** on the the state to ensure it's correct and as expected.

#### Commit your changes to git 

* Do a `git add .` and `git commit -m ".."` as before. Ensure that only the `main.tf` file gets added.

* Optionally, push it your remote if you have it setup.

----
