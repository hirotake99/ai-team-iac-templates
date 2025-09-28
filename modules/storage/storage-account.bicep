@description('ストレージアカウントの名前')
param storageAccountName string

@description('ストレージアカウントのロケーション')
param location string = resourceGroup().location

@description('ストレージアカウントのタイプ')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output storageAccountPrimaryKey string = storageAccount.listKeys().keys[0].value
