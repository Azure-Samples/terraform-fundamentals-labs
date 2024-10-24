#### Understand the terraform core workflow. (write, plan, apply)

## Terraform Core Workflow

* Write
* Plan 
* Apply

## Day 2 operation (update)

**Write**

Open `main.tf` on the editor and add a `tag` by making the below change within `contoso_rg` resource

```terraform
tags = {
    "cost_center" = "contoso research"
}
```
It should look something like below

``` terraform
resource "azurerm_resource_group" "contoso_rg" {
    name = "contoso_rg"
    location = "UK South"

    tags = {
        "cost_center" = "contoso research"
    } 
}
```

* Save `main.tf` 

> Note: we are not doing an `init` this time because the `.terraform` folder and `azure provider` plugin is already available from our previous run. When running in a `CI / CD` pipeline, this step may be required.

**Plan**

Do a `terraform plan` but this time we are also storing the **`output`** in a separate `.tfplan` file

```bash
terraform plan -out contoso.tfplan
```  

Take a look at the plan file that's been created using **`show`** command as before.

```bash
terraform show contoso.tfplan
```   
You should see something like below

```
An execution plan has been generated and is shown below.
Terraform will perform the following actions:

  # azurerm_resource_group.contoso_rg will be updated in-place
  ~ resource "azurerm_resource_group" "contoso_rg" {
        id ="...."
        ....other properties..
      ~ tags     = {
          + "cost_center = "contoso research"
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```
> Note: Much like, .tfstate, .tfplan files can also contain sensitive information and should be kept as secure as possible. It is also in `.gitignore` of this repo.

> See: https://www.terraform.io/docs/commands/plan.html#security-warning

**Apply**

Pass the plan file to terraform apply and this time, we also do an `-auto-approve`, so we are not prompted for approval.

```bash
# Note: ordering of args is important in this case.
terraform apply -auto-approve "contoso.tfplan"
```

The terminal output should state something like below

```bash
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

**Verify**

Verify that `cost_center` tag has been created on our resource group.

```bash
# You can use the portal or run the below azure cli command
az group show --name "contoso_rg"
```

Take a quick look at the state file as well.

```bash
terraform show terraform.tfstate
```
---

#### Version control your code (as done before, feel free to give your own commit message)

* Add `main.tf` to git

    ```bash
        # Make sure you're in right folder
        cd ~/clouddrive/tfw/contoso
        
        git add .
    ```

* Above should only include `main.tf` 

* Commit your changes

```bash
git commit -m "Added tags to resource group"
```

* _You are welcome to push your changes to your own remote if you prefer._

---