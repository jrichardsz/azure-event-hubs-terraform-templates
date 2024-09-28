terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.108.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.37.1"
    }
  }
}

# Random provider
provider "random" {}

# Subscription provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name = "rg-${var.base_name}-${var.environment}"
  location = var.location
}

resource "azurerm_eventhub_namespace" "acme_hub_ns" {
  name                = "acme-hub-ns"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1

  tags = var.tags
}

resource "azurerm_eventhub" "acme_hub_ns" {
  name                = "acme-hub"
  namespace_name      = azurerm_eventhub_namespace.acme_hub_ns.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 1
  message_retention   = 1
}

#Event hub Policy creation

resource "azurerm_eventhub_authorization_rule" "auth_policy" {
  name                = "navi"
  namespace_name      = azurerm_eventhub_namespace.acme_hub_ns.name
  eventhub_name       = azurerm_eventhub.acme_hub_ns.name
  resource_group_name = azurerm_resource_group.rg.name
  listen              = true
  send                = false
  manage              = false
}

# Service Prinicipal Assignment

resource "azurerm_role_assignment" "pod-identity-assignment" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Azure Event Hubs Data Owner"
  principal_id         = "${var.principal_id}"
}

# Checkpoint

resource "random_string" "suffix" {
  special = false
  upper = false
  length = 5
}

resource "azurerm_storage_account" "storage" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "${var.storage_account_name}${random_string.suffix.result}"
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = var.tags
}

resource "azurerm_storage_container" "acme_checkpoint" {
  name                 = "acme-checkpoint"
  storage_account_name = azurerm_storage_account.storage.name
}

resource "azurerm_role_assignment" "acme_checkpoint_blob_data_owner_to_subscriber_msi" {
  principal_id         = "${var.principal_id}"
  scope                = azurerm_storage_container.acme_checkpoint.resource_manager_id
  role_definition_name = "Storage Blob Data Owner"
}

# output

output "namespace_fqdn" {
  value = "${azurerm_eventhub_namespace.acme_hub_ns.name}.servicebus.windows.net"
}

output "container_url" {
  value = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.acme_checkpoint.name}"
}

