## Output Values (outputs)

#### Setup:
> Make sure you are in the correct folder

```bash
cd ~/clouddrive/tfw/contoso
```

## Outputs.tf

Similar to `variables.tf`, let's now create a new file called `outputs.tf`

* `outputs.tf` will be used to define the output values from resources created/updated.

```bash
cd ~/clouddrive/tfw/contoso/
code outputs.tf
```
Add `output` values definition such as below. Notice the use of `expressions` here to get the `id` of specified resource group.

```terraform
# outputs.tf
output "contoso_rg_id" {
    value = azurerm_resource_group.contoso_rg.id
    description = "don't show actual data on cli output"
    sensitive = true
}

output "contoso_dev_rg_id" {    
    value = azurerm_resource_group.contoso_dev_rg.id
}
```

#### Plan and apply

```bash
terraform plan -var-file="contoso.uk.tfvars"
terraform apply -auto-approve -var-file="contoso.uk.tfvars"
```

#### Verify

* Observe the output on terminal.
* Notice that one of them simply shows `sensitive`. This doesn't mean it's fully secure, anyone with access to state file can still get to that data.

```bash
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

contoso_dev_rg_id = /subscriptions/.../resourceGroups/contoso_dev_rg
contoso_rg_id = <sensitive>
```

#### Outputs via CLI

The following commands can be used to get outputs from state and values of sensitive outputs.

```bash
# Show all outputs
terraform output
```

```bash
# Show a specific output in json format
terraform output -json contoso_rg_id
```

```bash
# Show a specific output in raw format
terraform output -raw contoso_rg_id
```

#### Commit your code and clean up the infrastructure with `terraform destroy`

----

#### Recap:

Topics Covered: 
* https://www.terraform.io/docs/configuration/outputs.html
* https://www.terraform.io/docs/configuration/expressions.html

The contoso folder should now look like below.

```
contoso
|___.terraform/ 
|___contoso.europe.tfvars
|___contoso.tfplan
|___contoso.uk.tfvars
|___main.tf
|___outputs.tf
|___terraform.tfstate
|___terraform.tfstate.backup
|___terraform.tfvars
|___variables.tf
----