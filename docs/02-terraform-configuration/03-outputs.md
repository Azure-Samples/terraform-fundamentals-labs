---
layout: page
title: Terraform configuration
description: Lab 2 - Part 3 - Outputs
---

## Lab description

In this lab we learn about the `output` definition in Terraform.

## Outputs

### Setup

Make sure you are in the correct folder:

```powershell
cd ~/terraform-labs
```

```bash
cd ~/terraform-labs
```

If you were unable to complete the last lab, you can find a copy of the files in the [solutions folder]({{ site.github.repository_url }}/tree/main/docs/02-terraform-configuration/solutions/02)

### 1. Create `outputs.tf`

1. Similar to `variables.tf`, let's now create a new file called `outputs.tf`

    `outputs.tf` will be used to define the output values from resources created/updated.

    ```powershell
    cd ~/terraform-labs
    code outputs.tf
    ```

    ```bash
    cd ~/terraform-labs
    code outputs.tf
    ```

2. Add `output` values definition such as below. Notice the use of `expressions` here to get the `id` of specified resource group.

    ```terraform
    output "contoso_rg_id" {
      value       = azurerm_resource_group.contoso_rg.id
      description = "don't show actual data on cli output"
      sensitive   = true
    }
    
    output "contoso_dev_rg_id" {
      value = azurerm_resource_group.contoso_dev_rg.id
    }
    ```

### 2. Plan and apply

```powershell
terraform plan -var-file="contoso.uk.tfvars"
terraform apply -auto-approve -var-file="contoso.uk.tfvars"
```

```bash
terraform plan -var-file="contoso.uk.tfvars"
terraform apply -auto-approve -var-file="contoso.uk.tfvars"
```

### 3. Verify

1. Observe the output on terminal.
2. Notice that one of them simply shows `sensitive`. This doesn't mean it's fully secure, anyone with access to state file can still get to that data.

    ```text
    Changes to Outputs:
      + contoso_dev_rg_id = (known after apply)
      + contoso_rg_id     = (sensitive value)
    ```

### 4. Outputs via CLI

The following commands can be used to get outputs from state and values of sensitive outputs.

1. Show all outputs

    ```powershell
    terraform output
    ```

    ```bash
    terraform output
    ```

2. Show a specific output in json format

    ```powershell
    terraform output -json contoso_rg_id
    ```

    ```bash
    terraform output -json contoso_rg_id
    ```

3. Show a specific output in raw format

    ```powershell
    terraform output -raw contoso_rg_id
    ```

    ```bash
    terraform output -raw contoso_rg_id
    ```

### 5. Commit your code and clean up the infrastructure with `terraform destroy`

### 6. Recap

Topics Covered:

* <https://developer.hashicorp.com/terraform/language/values/outputs>
* <https://developer.hashicorp.com/terraform/language/expressions>

The folder should now look like below.

```text
📂terraform-labs
┣ 📂.terraform
┣ 📜.gitignore
┣ 📜.terraform.lock.hcl
┣ 📜contoso.europe.tfvars
┣ 📜contoso.tfplan
┣ 📜contoso.uk.tfvars
┣ 📜main.tf
┣ 📜outputs.tf
┣ 📜terraform.tfstate
┣ 📜terraform.tfstate.backup
┣ 📜terraform.tfvars
┗ 📜variables.tf
```

---
