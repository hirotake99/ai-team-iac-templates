// templates/ml-training-env/main.bicep
targetScope = 'subscription'

@description('プロジェクト名')
param projectName string

@description('環境名')
@allowed(['dev', 'test', 'prod'])
param environment string

@description('リージョン')
param location string = 'japaneast'

var resourceGroupName = 'rg-${projectName}-${environment}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

output resourceGroupName string = resourceGroup.name
