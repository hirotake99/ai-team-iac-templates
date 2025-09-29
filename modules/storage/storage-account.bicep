@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the storage account.')
param storageAccountName string

@description('The SKU of the storage account.')
@allowed(['Standard_LRS', 'Standard_GRS', 'Standard_RAGRS', 'Standard_ZRS', 'Premium_LRS', 'Premium_ZRS', 'Standard_GZRS', 'Standard_RAGZRS'])
param skuName string = 'Standard_LRS'

@description('The access tier of the storage account.')
@allowed(['Hot', 'Cool'])
param accessTier string = 'Hot'

@description('Allow blob public access.')
param allowBlobPublicAccess bool = false

@description('Allow shared key access.')
param allowSharedKeyAccess bool = true

@description('Require infrastructure encryption.')
param requireInfrastructureEncryption bool = false

@description('Enable HTTPS traffic only.')
param supportsHttpsTrafficOnly bool = true

@description('The minimum TLS version.')
@allowed(['TLS1_0', 'TLS1_1', 'TLS1_2'])
param minimumTlsVersion string = 'TLS1_2'

@description('Array of container names to create.')
param containerNames array = []

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    encryption: {
      requireInfrastructureEncryption: requireInfrastructureEncryption
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
    }
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    minimumTlsVersion: minimumTlsVersion
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = if (!empty(containerNames)) {
  parent: storageAccount
  name: 'default'
}

resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = [for containerName in containerNames: {
  parent: blobService
  name: containerName
  properties: {
    publicAccess: 'None'
  }
}]

@description('The resource ID of the storage account.')
output storageAccountId string = storageAccount.id

@description('The name of the storage account.')
output storageAccountName string = storageAccount.name

@description('The primary endpoints of the storage account.')
output primaryEndpoints object = storageAccount.properties.primaryEndpoints

@description('The connection string of the storage account.')
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, '2023-05-01').keys[0].value};EndpointSuffix=${environment().suffixes.storage}'