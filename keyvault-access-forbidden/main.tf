terraform {
  required_version = "~> 1.9"
}

provider "azurerm" {
  features {}
}

locals {
  resource_group_name = "disk-encryption-rg"
  user_managed_identity_name = "disk-encryption-set-identity"
  disk_encryption_set_name = "disk-encryption-set"

  location = "germanywestcentral"
  enable_avm_telemetry = true

  keys = {
    "disk_encryption" = {
      name     = "disk-encryption-key"
      key_size = 2048
      key_type = "RSA"
      key_opts = ["wrapKey", "unwrapKey"]
    }
  }
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

resource "azurerm_resource_group" "this" {
  location = local.location
  name     = local.resource_group_name
}

data "azurerm_client_config" "this" {}

module "keyvault" {
  source                      = "Azure/avm-res-keyvault-vault/azurerm"
  version                     = "0.9.1"

  enable_telemetry                = local.enable_avm_telemetry
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = false
  keys                            = local.keys
  location                        = local.location
  name                            = module.naming.key_vault.name_unique
  public_network_access_enabled   = true
  purge_protection_enabled        = true
  resource_group_name             = azurerm_resource_group.this.name
  sku_name                        = "standard"
  soft_delete_retention_days      = 90
  tenant_id                       = data.azurerm_client_config.this.tenant_id

  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}

module "user_managed_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.3.3"

  enable_telemetry    = local.enable_avm_telemetry
  location            = local.location
  name                = local.user_managed_identity_name
  resource_group_name = azurerm_resource_group.this.name
}

module "disk_encryption_set" {
  source  = "Azure/avm-res-compute-diskencryptionset/azurerm"
  version = "0.1.0"

  enable_telemetry      = local.enable_avm_telemetry
  encryption_type       = "EncryptionAtRestWithCustomerKey"
  key_vault_key_id      = module.keyvault.keys_resource_ids["disk_encryption"].id
  key_vault_resource_id = module.keyvault.resource_id
  location              = local.location
  name                  = local.disk_encryption_set_name
  resource_group_name   = azurerm_resource_group.this.name

  managed_identities    =  {
    system_assigned = false
    user_assigned_resource_ids = [
      module.user_managed_identity.resource_id
    ]
  }
}
