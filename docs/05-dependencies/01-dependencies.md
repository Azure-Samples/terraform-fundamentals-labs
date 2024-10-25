---
layout: page
title: Dependencies
description: Lab 5 - Part 1 - Implicit Dependencies
---

## Lab description

In this lab we learn about implicit dependencies in Terraform.

## Understand how implict dependencies work

### Setup

Make sure you are in the correct folder:

```powershell
cd ~/terraform-labs
```

```bash
cd ~/terraform-labs
```

If you were unable to complete the last lab, you can find a copy of the files in the [solutions folder]({{ site.github.repository_url }}/tree/main/docs/04-data-sources-and-refactoring/solutions/01)

### 1. Create a vnet for every resource group we've been creating

1. Add a new variable to `variables.tf` so it can accept some vnet specific details

    Notice the usage of a complex type here

    ```terraform
    variable "virtual_networks" {
      type = map(object({
        name               = string
        resource_group_key = string
        address_space      = list(string)
        subnets = map(object({
          name           = optional(string)
          address_prefix = string
        }))
      }))
      description = "The virtual networks to deploy"
    }
    ```

    > NOTE: The `optional` function is used to indicate that the value is not required. This is useful when you want to allow a value to be omitted from the configuration to provide a sensisble default. In this case the subnet name is optional.

1. Provide an input for the `virtual_networks` variable in `terraform.tfvars`.

    ```terraform
    virtual_networks = {
      dev = {
        name               = "vnet-dev"
        resource_group_key = "dev"
        address_space      = ["10.0.0.0/16"]
        subnets = {
          subnet1 = {
            name           = "subnet-dev-1"
            address_prefix = "10.0.0.0/24"
          }
        }
      }
      staging = {
        name               = "vnet-staging"
        resource_group_key = "staging"
        address_space      = ["10.1.0.0/16"]
        subnets = {
          subnet1 = {
            name           = "subnet-staging-1"
            address_prefix = "10.1.0.0/24"
          }
        }
      }
      prod = {
        name               = "vnet-prod"
        resource_group_key = "prod"
        address_space      = ["10.2.0.0/16"]
        subnets = {
          subnet1 = {
            address_prefix = "10.2.0.0/24"
          }
          subnet2 = {
            address_prefix = "10.2.1.0/24"
          }
        }
      }
    }
    ```

    > NOTE: The prod subnets do not have a name specified. This is because the name is optional and we'll us ethe key to create the name.

1. Update the locals block to `main.tf` to format the subnets

    Make sure to replace the contents of the `locals` block with the following:

    ```terraform
    locals {
      subnets = { for subnet in flatten([
        for virtual_network_key, virtual_network_value in var.virtual_networks : [
          for subnet_key, subnet_value in virtual_network_value.subnets : {
            composite_key        = "${virtual_network_key}-${subnet_key}"
            name                 = subnet_value.name == null ? "${virtual_network_value.name}-${subnet_key}" : subnet_value.name
            address_prefix       = subnet_value.address_prefix
            resource_group_name  = azurerm_resource_group.demo[virtual_network_value.resource_group_key].name
            virtual_network_name = azurerm_virtual_network.demo[virtual_network_key].name
          }
        ]
      ]) : subnet.composite_key => subnet }
    }
    ```

    Take note of the following:

    * The ternary expression is used to provide a default value if the value is not set. In this case we are using the subnet key to create a default name.
    * The expression for the resource group and virtual network names are creating implicit dependencies on the resource groups and virtual networks.
    * We are using a nested `for` expression to iterate over the virtual networks and subnets to create a single set of subnets. We use the `flatten` function to convert the nested list into a single list.

1. Add new resource blocks to `main.tf` to create the virtual networks and subnets

    ```terraform
    resource "azurerm_virtual_network" "demo" {
      for_each            = var.virtual_networks
      name                = each.value.name
      address_space       = each.value.address_space
      location            = var.region
      resource_group_name = azurerm_resource_group.demo[each.value.resource_group_key].name
    }
    
    resource "azurerm_subnet" "demo" {
      for_each             = local.subnets
      name                 = each.value.name
      resource_group_name  = each.value.resource_group_name
      virtual_network_name = each.value.virtual_network_name
      address_prefixes     = [each.value.address_prefix]
    }
    ```

    Take note of the following:

    * The `resource_group_name` of the virtual network is set to the name of the resource group. This creates an implicit dependency on the resource group.

### 3. Plan and apply

1. Run a `terraform plan`.

    The output should look like this:

    ```text
    Terraform will perform the following actions:

      # azurerm_subnet.demo["dev-subnet1"] will be created
      + resource "azurerm_subnet" "demo" {
          + address_prefixes                              = [
              + "10.0.0.0/24",
            ]
          + default_outbound_access_enabled               = true
          + id                                            = (known after apply)
          + name                                          = "subnet-dev-1"
          + private_endpoint_network_policies             = "Disabled"
          + private_link_service_network_policies_enabled = true
          + resource_group_name                           = "contoso_research_dev_rg"
          + virtual_network_name                          = "vnet-dev"
        }
    
      # azurerm_subnet.demo["prod-subnet1"] will be created
      + resource "azurerm_subnet" "demo" {
          + address_prefixes                              = [
              + "10.2.0.0/24",
            ]
          + default_outbound_access_enabled               = true
          + id                                            = (known after apply)
          + name                                          = "vnet-prod-subnet1"
          + private_endpoint_network_policies             = "Disabled"
          + private_link_service_network_policies_enabled = true
          + resource_group_name                           = "contoso_research_prod_rg"
          + virtual_network_name                          = "vnet-prod"
        }
    
      # azurerm_subnet.demo["prod-subnet2"] will be created
      + resource "azurerm_subnet" "demo" {
          + address_prefixes                              = [
              + "10.2.1.0/24",
            ]
          + default_outbound_access_enabled               = true
          + id                                            = (known after apply)
          + name                                          = "vnet-prod-subnet2"
          + private_endpoint_network_policies             = "Disabled"
          + private_link_service_network_policies_enabled = true
          + resource_group_name                           = "contoso_research_prod_rg"
          + virtual_network_name                          = "vnet-prod"
        }
    
      # azurerm_subnet.demo["staging-subnet1"] will be created
      + resource "azurerm_subnet" "demo" {
          + address_prefixes                              = [
              + "10.1.0.0/24",
            ]
          + default_outbound_access_enabled               = true
          + id                                            = (known after apply)
          + name                                          = "subnet-staging-1"
          + private_endpoint_network_policies             = "Disabled"
          + private_link_service_network_policies_enabled = true
          + resource_group_name                           = "contoso_research_staging_rg"
          + virtual_network_name                          = "vnet-staging"
        }
    
      # azurerm_virtual_network.demo["dev"] will be created
      + resource "azurerm_virtual_network" "demo" {
          + address_space       = [
              + "10.0.0.0/16",
            ]
          + dns_servers         = (known after apply)
          + guid                = (known after apply)
          + id                  = (known after apply)
          + location            = "northeurope"
          + name                = "vnet-dev"
          + resource_group_name = "contoso_research_dev_rg"
          + subnet              = (known after apply)
        }
    
      # azurerm_virtual_network.demo["prod"] will be created
      + resource "azurerm_virtual_network" "demo" {
          + address_space       = [
              + "10.2.0.0/16",
            ]
          + dns_servers         = (known after apply)
          + guid                = (known after apply)
          + id                  = (known after apply)
          + location            = "northeurope"
          + name                = "vnet-prod"
          + resource_group_name = "contoso_research_prod_rg"
          + subnet              = (known after apply)
        }
    
      # azurerm_virtual_network.demo["staging"] will be created
      + resource "azurerm_virtual_network" "demo" {
          + address_space       = [
              + "10.1.0.0/16",
            ]
          + dns_servers         = (known after apply)
          + guid                = (known after apply)
          + id                  = (known after apply)
          + location            = "northeurope"
        + name                = "vnet-staging"
        + resource_group_name = "contoso_research_staging_rg"
        + subnet              = (known after apply)
      }
  
    Plan: 7 to add, 0 to change, 0 to destroy.
    ```

1. Run a `terraform apply -auto-approve`.

### 3. Verify

1. Have a look at the virtual networks and subnets in the Azure portal.

### 4. Commit your code 

Commit your code into git.

### 5. Recap

Here, we've created a vnet for each of our resource groups by applying the concepts covered so far.

---
