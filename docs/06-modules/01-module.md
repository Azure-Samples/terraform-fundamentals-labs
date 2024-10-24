## Create a local module that encapsulates what we've created so far

#### Setup

> Make sure you are in the correct folder

```bash
cd ~/clouddrive/tfw/contoso
```

> Ensure that you have cleaned up resources from previous labs using `terraform destroy`. (state file should be empty as well)

---

#### Setup Module structure

Here, we will create a simple module called `contoso-az-connectedrg` that will create a resource group for given list of `rg_names` and create a `vnet` for each of them as well.

To get started, create a folder called modules and create the required config files as below.

```bash
# create the folders
mkdir -m modules/contoso-az-connectedrg

cd modules/contoso-az-connectedrg
touch README.md
touch main.tf
touch outputs.tf
touch variables.tf
cd ../../
# or 
# cd ~/clouddrive/tfw/contoso
```
The file structure from `contoso` should look like below.

```bash
├── contoso
│   ├── main.tf
│   ├── modules
│   │   └── contoso-az-connectedrg
│   │       ├── README.md
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       └── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   └── variables.tf
    |__...plus any other .tfvars...
```

#### Move the resource blocks into our new module

Move the resource blocks from  main.tf in contoso folder into main.tf in contoso-az-connectedrg

They should look like below. (Feel free to paste them over)

**Main.tf**

```terraform
# modules/contoso-az-connectedrg/main.tf
resource "azurerm_resource_group" "rgs" {  
    count = length(var.rg_names)
    name = "${var.prefix}_${var.rg_names[count.index]}"
    location = var.region
    tags = var.tags
}

resource "azurerm_virtual_network" "vnets" {
    count               = length(var.rg_names)
    name                = lookup(var.vnets[count.index], "name")
    address_space       = [lookup(var.vnets[count.index], "address")]
    location            = var.region
    resource_group_name = azurerm_resource_group.rgs[count.index].name
}
```

Now, call the above module from `main.tf` in `contoso` folder using module block.

```terraform
# contoso/main.tf (calling module)

# main.tf from calling module 
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

module "connectedrg" {
    # or remote git repo with ?ref=verion    
    source = "./modules/contoso-az-connectedrg"       
     
    rg_names = var.rg_names
    vnets = var.vnets
}
```

**variables.tf**

Move the variables into the module as below.

```terraform
# modules/contoso-az-connectedrg/variables.tf
variable rg_names {
    type = list(string)    
}

variable vnets {
    type = list(map(string))    
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
    default = {
        company = "contoso corp"
    }   
}
```

> variables.tf for calling module now only requires `vnets` and `rg_names`

```terraform
# contoso/variables.tf
variable rg_names {
    type = list(string)    
}

variable vnets {
    type = list(map(string))    
}
```

**outputs.tf**

Here, we return outputs from our new module and forward it to our calling module.

output files should look as below.

```terraform
# modules/contoso-az-connectedrg/outputs.tf
output "rg_ids" {    
    value = azurerm_resource_group.rgs.*.id   
}

output "vnet_ids" {    
    value = azurerm_virtual_network.vnets.*.id   
}

```
And now we refer to module resource's object

```terraform
# contoso/outputs.tf
output "resource_groups" {    
    value = module.connectedrg.rg_ids
}

output "vnets" {    
    value = module.connectedrg.vnet_ids
}
```

**terraform.tfvars**

And finally, we now pass in the values for `vnets` and `rg_names` from calling module.

Note that child modules don't require terraform.tfvars as we often pass the value in. There are some defaults in their `variables.tf` however for our convenience.

```terraform
# contoso/terraform.tfvars
rg_names = [
    "research_dev_rg",
    "research_staging_rg",
    "research_prod_rg"
]

vnets = [
    {
        name = "dev_vnet"
        address = "10.0.0.0/16"
    },
    {
        name = "staging_vnet"
        address = "10.1.0.0/16"
    },
    {
        name = "prod_vnet"
        address = "10.2.0.0/16"
    },
]
```
---

#### Plan

When you're ready, run a plan. Make sure you're in the correct folder.

```bash
cd ~/clouddrive/tfw/contoso
terraform plan
```

This will fail as we need to **`initialize`** our new module
```
Error: Module not installed

  on main.tf line 8:
   8: module "connectedrg" {

This module is not yet installed. Run "terraform init" to install all modules
required by this configuration.
```

> Run an Init

```bash
# From contoso folder 
terraform init
```

#### Plan

Run a plan. You should see an output similar to below. 

> If you're getting any errors at this stage or unsure, please reach out.

```bash
Terraform will perform the following actions:

  # module.connectedrg.azurerm_resource_group.rgs[0] will be created
  + resource "azurerm_resource_group" "rgs" {
      + id       = (known after apply)
      + location = "uksouth"
      + name     = "contoso_research_dev_rg"
      + tags     = {
          + "company" = "contoso corp"
        }
    }

  # module.connectedrg.azurerm_resource_group.rgs[1] will be created
  + resource "azurerm_resource_group" "rgs" {
      + id       = (known after apply)
      + location = "uksouth"
      + name     = "contoso_research_staging_rg"
      + tags     = {
          + "company" = "contoso corp"
        }
    }

  # module.connectedrg.azurerm_resource_group.rgs[2] will be created
  + resource "azurerm_resource_group" "rgs" {
      + id       = (known after apply)
      + location = "uksouth"
      + name     = "contoso_research_prod_rg"
      + tags     = {
          + "company" = "contoso corp"
        }
    }

  # module.connectedrg.azurerm_virtual_network.vnets[0] will be created
  + resource "azurerm_virtual_network" "vnets" {
      + address_space       = [
          + "10.0.0.0/16",
        ]
      + guid                = (known after apply)
      + id                  = (known after apply)
      + location            = "uksouth"
      + name                = "dev_vnet"
      + resource_group_name = "contoso_research_dev_rg"
      + subnet              = (known after apply)
    }

  # module.connectedrg.azurerm_virtual_network.vnets[1] will be created
  + resource "azurerm_virtual_network" "vnets" {
      + address_space       = [
          + "10.1.0.0/16",
        ]
      + guid                = (known after apply)
      + id                  = (known after apply)
      + location            = "uksouth"
      + name                = "staging_vnet"
      + resource_group_name = "contoso_research_staging_rg"
      + subnet              = (known after apply)
    }

  # module.connectedrg.azurerm_virtual_network.vnets[2] will be created
  + resource "azurerm_virtual_network" "vnets" {
      + address_space       = [
          + "10.2.0.0/16",
        ]
      + guid                = (known after apply)
      + id                  = (known after apply)
      + location            = "uksouth"
      + name                = "prod_vnet"
      + resource_group_name = "contoso_research_prod_rg"
      + subnet              = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.
```

#### Apply

When ready, perform an apply. You should receive an output such as below.

```
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

resource_groups = [
  "/subscriptions/.../resourceGroups/contoso_research_dev_rg",
  "/subscriptions/.../resourceGroups/contoso_research_staging_rg",
  "/subscriptions/.../resourceGroups/contoso_research_prod_rg",
]
vnets = [
  "/subscriptions/.../resourceGroups/contoso_research_dev_rg/providers/Microsoft.Network/virtualNetworks/dev_vnet",
  "/subscriptions/.../resourceGroups/contoso_research_staging_rg/providers/Microsoft.Network/virtualNetworks/staging_vnet",
  "/subscriptions/.../resourceGroups/contoso_research_prod_rg/providers/Microsoft.Network/virtualNetworks/prod_vnet",
]
```

#### Verify

As done before, verify the changes. 

#### Commit the changes to git.

----

#### [Optional]

If you have a remote git repo setup, create a new repo called `tf-modules` or something similar and copy the module to remote. Then you should be able to refer to the remote repo.

Additionally, you can also `tag` a commit and use it for versioning the `module`

---

#### RECAP

See more: https://www.terraform.io/docs/modules/index.html

> We've covered a handful of core terraform concepts thus far. Take your time to familiarize yourself with the topics we've covered so far and feel free to repeat the labs as needed.

Also take a look at commands such as `fmt` and `taint` 
* `fmt` will format the config according to style guide.
> https://www.terraform.io/docs/commands/fmt.html

* `taint` will mark a resource as tainted / corrupted and force `recreation` upon next apply. 
> https://www.terraform.io/docs/commands/taint.html
----
