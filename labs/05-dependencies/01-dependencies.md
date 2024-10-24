# Understand how resource dependencies work 

#### Setup

> Make sure you are in the correct folder

```bash
cd ~/clouddrive/tfw/contoso
```

> Ensure that you have cleaned up resources from previous labs using `terraform destroy`. (state file should be empty as well)

---

#### Create a vnet for every resource group we've been creating.

Add a new variable to `variables.tf` so it can accept some vnet specific details

Notice the usage of a complex type here

```terraform
# variables.tf
variable vnets {
    type = list(map(string))    
}
```

Provide some values to `vnets` variable in terraform.tfvars

```terraform
# terraform.tfvars
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

And finally, add a new resource block to `main.tf` to create `vnet`

Observe the usage of `lookup` function here as well as implicit dependency usage for resource_group_name

> Feel free to take your time to type this in and become familiar with the syntax

```terraform
# main.tf
resource "azurerm_virtual_network" "vnets" {
    count               = length(var.rg_names)
    name                = lookup(var.vnets[count.index], "name")
    address_space       = [lookup(var.vnets[count.index], "address")]
    location            = var.region
    resource_group_name = azurerm_resource_group.rgs[count.index].name
}
```

#### Plan and apply

When you're ready run a plan and then apply

---

#### Finished setup.(in case of any issues)
> Please reach out if you are having any errors and require a completed solution thus far of all config files.
---

#### Verify

Have a look through the resource groups and ensure that a vnet resource has been created in each of them.

#### Clean up the infrastructure

Do a `terraform destroy` and clean up the infrastructure

---

#### Commit your code 

Commit your code into git.

---

#### Recap

Here, we've created a vnet for each of our resource groups by applying the concepts covered so far.

> See below for more details: 
https://www.terraform.io/docs/configuration/resources.html#resource-dependencies

---


