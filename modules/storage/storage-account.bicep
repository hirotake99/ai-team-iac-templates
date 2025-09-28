// =============================================================================
// フェーズ 1: シチュエーションによって変わるパラメータの定義
// 「ストレージアカウント名」と「ロケーション」は、templatesのmain.bicepで記載する
// =============================================================================
@description('ストレージアカウントの名前')
param storageAccountName string
@description('ストレージアカウントのロケーション')
param location string = resourceGroup().location

// =============================================================================
// フェーズ 2: 共通設定パラメータ（デフォルト値あり）
// =============================================================================
@description('Tags to apply to the storage account')
param tags object = {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output storageAccountPrimaryKey string = storageAccount.listKeys().keys[0].value
