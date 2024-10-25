---
layout: page
title: Terraform core workflow
description: Lab 1 - Part 3 - Day n Operations - write, plan and destroy
---

## Lab description

This lab will cover the very basic terraform workflow for the updating of resources in Azure.

The terraform Core Workflow is still:

* Write
* Init (not needed this time)
* Plan
* Apply (a destroy plan this time)

## Day n operation (destroy)

### 1. Plan

Run a plan to see what will be destroyed.

```powershell
terraform plan -destroy -out contoso.tfplan
```

```bash
terraform plan -destroy -out contoso.tfplan
```

Your plan should look something like below:

```text
azurerm_resource_group.contoso_rg: Refreshing state... [id=/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_rg]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # azurerm_resource_group.contoso_rg will be destroyed
  - resource "azurerm_resource_group" "contoso_rg" {
      - id         = "/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_rg" -> null
      - location   = "uksouth" -> null
      - name       = "contoso_rg" -> null
      - tags       = {
          - "cost_center" = "contoso research"
        } -> null
        # (1 unchanged attribute hidden)
    }

Plan: 0 to add, 0 to change, 1 to destroy.

───────────────────────────────────────────────────────

Saved the plan to: contoso.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "contoso.tfplan"
```

### 2. Destroy

If the plan looks as expected, go ahead and remove the resource group that we created using `destroy` operation.

`Destroy` depends on your state file to decide what needs to be removed. Unlike apply it cannot be invoked with a `.tfplan` file.

> Note that a shortcut to performing a destroy plan and apply is `terraform destroy`.

```powershell
terraform apply "contoso.tfplan"
```

```bash
terraform apply "contoso.tfplan"
```

You should see a terminal output like this:

```text
azurerm_resource_group.contoso_rg: Destroying... [id=/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_rg]
azurerm_resource_group.contoso_rg: Still destroying... [id=/subscriptions/b857908d-3f5c-4477-91c1-0fbd08df4e88/resourceGroups/contoso_rg, 10s elapsed]
azurerm_resource_group.contoso_rg: Destruction complete after 15s

Apply complete! Resources: 0 added, 0 changed, 1 destroyed.
```

### 3. Verify

Verify that the `contoso_rg` resource group has been deleted from your azure subscription.

```powershell
az group show --name "contoso_rg"
```

```bash
az group show --name "contoso_rg"
```

The state file should now be empty as we have completely cleaned up our terraform managed infrastructure.

```powershell
terraform show terraform.tfstate
```

```bash
terraform show terraform.tfstate
```

### 4. Recap

Here is a list of commands covered so far:

* init
* plan
  * plan -out "planfile"
* apply
  * apply "planfile"
* show
* destroy

If you have managed to finish this lab ahead of time, feel free to spend some time around the docs and try out above commands with other options.

Just make sure to clean up the infrastructure prior to next lab.

* <https://developer.hashicorp.com/terraform/cli/commands/init>
* <https://developer.hashicorp.com/terraform/cli/commands/plan>
* <https://www.terraform.io/docs/commands/apply.html>
* <https://developer.hashicorp.com/terraform/cli/commands/show>
* <https://developer.hashicorp.com/terraform/cli/commands/destroy>

### 5. Graph (optional bonus lab)

Take a look at the **`graph`** command. Terraform builds a dependency graph from the Terraform configurations, and walks this graph to generate plans, refresh state, and more

See:

* <https://developer.hashicorp.com/terraform/cli/commands/graph>
* <https://developer.hashicorp.com/terraform/internals/graph>

To see the graph in svg format, `graphviz` needs to be installed. This will not work in cloud shell as there isn't sudo access, but should work on vs code online. (or local environments) <http://www.graphviz.org/download>.
