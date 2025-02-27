## Steps
```bash
$ terraform init
$ terraform plan -out=tfplan
$ terraform apply tfplan
```

## Result
```bash
module.disk_encryption_set.azurerm_disk_encryption_set.this: Creating...
╷
│ Error: creating Disk Encryption Set (Subscription: "fc81e4c5-5743-42d9-bdf8-7e794257d3ab"
## Actual
```bash
module.disk_encryption_set.azurerm_disk_encryption_set.this: Creating...
╷
│ Error: creating Disk Encryption Set (Subscription: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
│ Resource Group Name: "disk-encryption-rg"
│ Disk Encryption Set Name: "disk-encryption-set"): performing CreateOrUpdate: unexpected status 400 (400 Bad Request) with error: KeyVaultAccessForbidden: Unable to access key vault resource 'https://kv-xxxx.vault.azure.net/keys/disk-encryption-key/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' to enable encryption at rest. Please grant get, wrap and unwrap key permissions to user-assigned identity '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/disk-encryption-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/disk-encryption-set-identity'. Please visit https://aka.ms/keyvaultaccessssecmk for more information.
│
│   with module.disk_encryption_set.azurerm_disk_encryption_set.this,
│   on .terraform/modules/disk_encryption_set/main.tf line 12, in resource "azurerm_disk_encryption_set" "this":
│   12: resource "azurerm_disk_encryption_set" "this" {
```