targetScope = 'resourceGroup'

@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The name of the function app.')
param functionAppName string = 'func-${uniqueString(resourceGroup().id)}'

@description('The name of the app service plan.')
param appServicePlanName string = 'plan-${uniqueString(resourceGroup().id)}'

@description('The SKU of the app service plan.')
@allowed(['Y1', 'EP1', 'EP2', 'EP3', 'P1V2', 'P2V2', 'P3V2'])
param appServicePlanSkuName string = 'Y1'

@description('The tier of the app service plan.')
@allowed(['Dynamic', 'ElasticPremium', 'PremiumV2'])
param appServicePlanSkuTier string = 'Dynamic'

@description('The runtime stack for the function app.')
@allowed(['dotnet', 'java', 'node', 'python', 'powershell'])
param runtime string = 'node'

@description('The version of the runtime.')
param runtimeVersion string = '18'

@description('The name of the storage account.')
param storageAccountName string = 'stor${uniqueString(resourceGroup().id)}'

@description('The SKU of the storage account.')
@allowed(['Standard_LRS', 'Standard_GRS', 'Standard_ZRS'])
param storageAccountSku string = 'Standard_LRS'

@description('The name of the Application Insights component.')
param applicationInsightsName string = 'appi-${uniqueString(resourceGroup().id)}'

@description('Enable HTTPS only.')
param httpsOnly bool = true

@description('Enable always on (not available for Consumption plan).')
param alwaysOn bool = false

@description('Custom application settings.')
param appSettings object = {}

@description('Tags to apply to all resources.')
param tags object = {
  environment: 'dev'
  project: 'ai-team'
  owner: 'devops-team'
}

module storageAccount '../../modules/storage/storage-account.bicep' = {
  name: 'storageAccount'
  params: {
    location: location
    storageAccountName: storageAccountName
    skuName: storageAccountSku
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

module applicationInsights '../../modules/monitoring/application-insights.bicep' = {
  name: 'applicationInsights'
  params: {
    location: location
    applicationInsightsName: applicationInsightsName
    applicationType: 'web'
    retentionInDays: 90
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

module functionApp '../../modules/web/function-app.bicep' = {
  name: 'functionApp'
  params: {
    location: location
    functionAppName: functionAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    appServicePlanSkuTier: appServicePlanSkuTier
    runtime: runtime
    runtimeVersion: runtimeVersion
    storageAccountId: storageAccount.outputs.storageAccountId
    storageAccountConnectionString: storageAccount.outputs.connectionString
    applicationInsightsId: applicationInsights.outputs.applicationInsightsId
    applicationInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    httpsOnly: httpsOnly
    alwaysOn: alwaysOn
    appSettings: appSettings
  }
}

resource resourceGroupTags 'Microsoft.Resources/tags@2022-09-01' = if (!empty(tags)) {
  name: 'default'
  properties: {
    tags: tags
  }
}

@description('The resource ID of the function app.')
output functionAppId string = functionApp.outputs.functionAppId

@description('The name of the function app.')
output functionAppName string = functionApp.outputs.functionAppName

@description('The default host name of the function app.')
output functionAppUrl string = 'https://${functionApp.outputs.defaultHostName}'

@description('The resource ID of the storage account.')
output storageAccountId string = storageAccount.outputs.storageAccountId

@description('The name of the storage account.')
output storageAccountName string = storageAccount.outputs.storageAccountName

@description('The resource ID of the Application Insights component.')
output applicationInsightsId string = applicationInsights.outputs.applicationInsightsId

@description('The name of the Application Insights component.')
output applicationInsightsName string = applicationInsights.outputs.applicationInsightsName
