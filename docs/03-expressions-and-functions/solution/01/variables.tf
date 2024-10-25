variable "resource_groups" {
  type        = map(string)
  description = "The resource groups to deploy"
}

variable "prefix" {
  type        = string
  description = "A prefix for all resources"
  default     = "contoso"
}

variable "region" {
  type        = string
  default     = "North Europe"
  description = "The Azure region to deploy resources"
  validation {
    condition     = contains(["UK South", "UK West", "North Europe", "West Europe", "East US", "West US"], var.region)
    error_message = "Invalid region"
  }
}

variable "tags" {
  type        = map(any)
  description = "A map of tags"
}