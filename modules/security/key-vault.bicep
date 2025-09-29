@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the Key Vault.')
param keyVaultName string

@description('The SKU name of the Key Vault.')
@allowed(['standard', 'premium'])
param skuName string = 'standard'

@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates.')
param enabledForDeployment bool = false

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets.')
param enabledForDiskEncryption bool = false

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets.')
param enabledForTemplateDeployment bool = false

@description('Specifies whether soft delete is enabled for this Key Vault.')
param enableSoftDelete bool = true

@description('The number of days to retain deleted vaults.')
param softDeleteRetentionInDays int = 90

@description('Property to specify whether the soft delete functionality is enabled.')
param enablePurgeProtection bool = false

@description('Array of access policies object.')
param accessPolicies array = []

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: skuName
    }
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection ? true : null
    accessPolicies: accessPolicies
  }
}

@description('The resource ID of the Key Vault.')
output keyVaultId string = keyVault.id

@description('The name of the Key Vault.')
output keyVaultName string = keyVault.name

@description('The URI of the Key Vault.')
output keyVaultUri string = keyVault.properties.vaultUri