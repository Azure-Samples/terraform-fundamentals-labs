## Know how to secure the state file using `tf-backend`

#### Setup

> Make sure you are in the correct folder

```bash
cd ~/clouddrive/tfw/contoso
```

> Ensure that you have cleaned up resources from previous labs using `terraform destroy`. (state file should be empty as well)

---

#### Create a storage account and a blob container to hold the state file

> Use below script to create a storage account (or see azure docs)

```bash
#!/bin/bash

RESOURCE_GROUP_NAME=tfstate
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location uksouth

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
```

```
# Take a look at the script and see what it does
cat storage_setup.sh

# provide execution rights
chmod +x storage_setup.sh

# Run the script and take note of output
./storage_setup.sh
```


#### Create a terraform block in `main.tf` to include the backend configuration 

> From `contoso/main.tf`, add the following to beginning of the file and fill it with your storage account details.

```terraform
terraform {
  backend "azurerm" {
    resource_group_name   = "tfstate"
    storage_account_name  = "<your_storage_account_name>"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.34.0"
    }
  }
}
```

#### Get rid of the existing plugins, state files, etc.

To make sure, nothing gets in the way remove `terraform.tfstate`, `terraform.tfstate.backup` and `.terraform` folder as well. 

> Note: In real world scenario, you may want to migrate your existing state from local to remote. For the purpose of lab, we are starting out with directly deploying to remote from onset.

```bash
# make sure you are in right directory
cd ~/clouddrive/tfw/contoso
rm terraform.tfstate terraform.tfstate.backup
rm -rf .terraform/
```

#### Init, Plan and Apply

Do an init, plan and apply. 

> Initialize
```
# The output from init should setup a remote backend.
terraform init

# You can take a quick look at `.terraform` folder if interested to see what it's in its `state` file.
```

#### If you run into any issues, remove `.terraform` folder and do an init again.

>Plan
```
terraform plan
```

> When ready, Apply
```
Apply
```

#### Verify

* Verify the resources that were created
* Take a look at the state file in the blob container of your storage account and make sure it's updated too.
* There shouldn't be any more local state file in `contoso` folder.

---

#### [Bonus Tasks if you have time]

Feel free to carry on with below ones if you have finished the labs ahead of time.

#### Locking 

If you are interested, open two terminals and try doing a `terraform apply` on each (don't proceed with approval). You should find that the second one will fail because the first apply still has the `tfstate` file locked.

* Take a look at locking here
    *  https://www.terraform.io/docs/state/locking.html

#### Partial Config

At the moment, we have the storage account name hard-coded in `main.tf`

We can use `partial config` feature during initialization stage to pass this value.

To avoid any issues, destroy the existing environment and remove any plugins.
```bash
cd ~/clouddrive/tfw/contoso
terraform destroy
rm -rf .terraform/

**Remove below line of code from `main.tf`**

```terraform
storage_account_name  = "<your_sg_account>"
```

# Now init with partial config (pass in your storage account name)
terraform init -backend-config="storage_account_name=your-sg-account"
```

> Plan and apply. It should work the same way as before.
---

#### Commit and clean up your infrastructure

> Do a git commit and download the repo or push it to your remote for reference or further learning.
> clean up the infrastructure (including the storage account and any credentials)

--- 

Recap:

* Terraform Backend Docs- https://www.terraform.io/docs/backends/index.html
* AzureRM Backend - https://www.terraform.io/docs/backends/types/azurerm.html
