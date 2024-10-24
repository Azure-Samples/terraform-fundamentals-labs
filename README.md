---
page_type: sample
languages:
- terraform
- hcl
name: Terraform on Azure Fundamentals Lab
description: A set of labs to introduce Terraform on Azure
products:
- azure
urlFragment: terraform-fundamentals-labs
---

# Terraform on Azure Fundamentals Labs

This is a set of labs that introduce Terraform on Azure. The labs are designed to be completed in order, with each one building on the previous one. 

The labs can be completed independently or as part of a Microsoft workshop. Please contact your Microsoft representative for more information on the full training course.

* Course Type: CIP
* Course Title: Introduction to Infrastructure as Code using Terraform

## Content

| File/folder | Description |
|-------------|-------------|
| `labs` | The files for the labs. |
| `.gitignore` | Define what to ignore at commit time. |
| `CHANGELOG.md` | List of changes to the sample. |
| `CONTRIBUTING.md` | Guidelines for contributing to the sample. |
| `README.md` | This README file. |
| `LICENSE.md` | The license for the sample. |

## Features

This sample has labs covering:

* Core Terraform workflow
* Terraform configuration
* Expressions and Functions
* Data Sources and Refactoring
* Dependencies
* Modules
* Remote State
* Continuous Delivery with GitHub and Azure DevOps

## Getting Started

### Prerequisites

* HashiCorp Terraform CLI Version 1.9 or higher: [Download](https://www.terraform.io/downloads)
* Git: [Download](https://git-scm.com/downloads)
* Visual Studio Code: [Download](https://code.visualstudio.com/)
  * Azure Terraform Extension for Visual Studio Code: [Install](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureterraform)
  * HashiCorp Terraform Extension for Visual Studio Code: [Install](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)
* Azure CLI: [Download](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli#install-or-update)
* An Azure Subscription: [Free Account](https://azure.microsoft.com/en-gb/free/search/)

### Quickstart

The instructions for this sample are in the form of a Lab. Follow along with them to get up and running.

## Lab 1: Core Terraform Workflow

* [Day 1 Operations](1_core_workflow/day1_operation.md)
* [Day 2 Operations](1_core_workflow/day2_operation.md)
* [Day N Operations](1_core_workflow/dayn_operation.md)

## Lab 2: Terraform Configuration

* [Locals](2_tf_config/1_locals.md)
* [Variables](2_tf_config/2_variables.md)
* [Outputs](2_tf_config/3_outputs.md)

## Lab 3: Expressions and Functions

* [Expressions](3_expressions_and_functions/1_expressions.md)
* [Functions](3_expressions_and_functions/2_functions.md)

## Lab 4: Data Sources and Imports

* [Import Resources](4_data_sources_and_imports/1_import_resources.md)

## Lab 5: Dependencies

* [Dependencies](5_dependencies/1_dependencies.md)

## Lab 6: Modules

* [Modules](6_modules/1_module.md)

## Lab 7: Remote State

* [Remote State](7_remote_state/1_remote_state.md)

## Lab 8: Continuous Delivery

* [Option 1: GitHub](9_continuous_delivery/1_github.md)
* [Option 2: Azure DevOps](9_continuous_delivery/2_azure_devops.md)
