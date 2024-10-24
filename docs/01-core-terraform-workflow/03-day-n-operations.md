#### Understand the terraform core workflow. (write, plan, apply)

## Day n operation (destroy)

**plan**

Run a plan to see what will be destroyed.

```bash
# make sure you are running this from the contoso folder
terraform plan -destroy


```

**destroy**

If the plan looks as expected, go ahead and remove the resource group that we created using `destroy` operation.

`Destroy` depends on your state file to decide what needs to be removed. Unlike apply it cannot be invoked with a `.tfplan` file.

```bash
terraform destroy

# this is the equivalent of command
terraform apply -destroy
```

You should see a terminal output stating what will be destroyed.

When prompted, type `yes` to approve. This operation may take some time, and terraform will provide status updates every 10 seconds or so.

_Example Screenshot_:

![destroy_example](../assets/destroy_example.png)


**Verify**

Verify that the `contoso_rg` resource group has been deleted from your azure subscription.

```bash
# You can use the portal or run the below azure cli command
az group show --name "contoso_rg"
```

The state file should now be empty as we have completely cleaned up our terraform managed infrastructure.

```bash
terraform show terraform.tfstate
```

---

## Recap

#### List of commands covered so far

* init
* plan
    * plan -out "planfile"
* apply
    * apply -auto-approve "planfile"
* show
* destroy 

If you have managed to finish this lab ahead of time, feel free to spend some time around the docs and try out above commands with other options. 

Just make sure to clean up the infrastructure prior to next lab.

* https://www.terraform.io/docs/commands/init.html
* https://www.terraform.io/docs/commands/plan.html
* https://www.terraform.io/docs/commands/apply.html
* https://www.terraform.io/docs/commands/show.html
* https://www.terraform.io/docs/commands/destroy.html

---

[**Optional / Bonus task**]

Take a look at **`graph`** command. Terraform builds a dependency graph from the Terraform configurations, and walks this graph to generate plans, refresh state, and more

See: 
* https://www.terraform.io/docs/commands/graph.html
* https://www.terraform.io/docs/internals/graph.html

> Note: To see the graph in svg format, `graphviz` needs to be installed. This will not work in cloud shell as there isn't sudo access, but should work on vs code online. (or local environments)

> http://www.graphviz.org/download/

For this lab, the resource graph would look something like below.

![resource_graph](../assets/graph_example.png)

----