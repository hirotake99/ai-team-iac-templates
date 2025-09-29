@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the function app.')
param functionAppName string

@description('The name of the app service plan.')
param appServicePlanName string

@description('The SKU of the app service plan.')
param appServicePlanSkuName string = 'Y1'

@description('The tier of the app service plan.')
param appServicePlanSkuTier string = 'Dynamic'

@description('The runtime stack for the function app.')
@allowed(['dotnet', 'java', 'node', 'python', 'powershell'])
param runtime string = 'node'

@description('The version of the runtime.')
param runtimeVersion string = '18'

@description('The resource ID of the storage account.')
param storageAccountId string

@description('The connection string of the storage account.')
@secure()
param storageAccountConnectionString string

@description('The resource ID of the Application Insights component.')
param applicationInsightsId string = ''

@description('The instrumentation key of the Application Insights component.')
@secure()
param applicationInsightsInstrumentationKey string = ''

@description('The connection string of the Application Insights component.')
@secure()
param applicationInsightsConnectionString string = ''

@description('Enable HTTPS only.')
param httpsOnly bool = true

@description('The minimum TLS version.')
@allowed(['1.0', '1.1', '1.2'])
param minTlsVersion string = '1.2'

@description('Enable remote debugging.')
param remoteDebuggingEnabled bool = false

@description('The remote debugging version.')
param remoteDebuggingVersion string = 'VS2022'

@description('Enable always on (not available for Consumption plan).')
param alwaysOn bool = false

@description('Custom application settings.')
param appSettings object = {}

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
    tier: appServicePlanSkuTier
  }
  properties: {
    reserved: contains(['node', 'python', 'java'], runtime)
  }
}

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: httpsOnly
    siteConfig: {
      minTlsVersion: minTlsVersion
      alwaysOn: appServicePlanSkuName != 'Y1' ? alwaysOn : false
      remoteDebuggingEnabled: remoteDebuggingEnabled
      remoteDebuggingVersion: remoteDebuggingVersion
    }
  }
}

resource functionAppSettings 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: union({
    AzureWebJobsStorage: storageAccountConnectionString
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccountConnectionString
    WEBSITE_CONTENTSHARE: toLower(functionAppName)
    FUNCTIONS_EXTENSION_VERSION: '~4'
    FUNCTIONS_WORKER_RUNTIME: runtime
  },
  !empty(applicationInsightsInstrumentationKey) ? {
    APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsightsInstrumentationKey
  } : {},
  !empty(applicationInsightsConnectionString) ? {
    APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsightsConnectionString
  } : {},
  runtime == 'node' ? {
    WEBSITE_NODE_DEFAULT_VERSION: '~${runtimeVersion}'
  } : {},
  runtime == 'python' ? {
    PYTHON_VERSION: runtimeVersion
  } : {},
  runtime == 'java' ? {
    JAVA_VERSION: runtimeVersion
  } : {},
  runtime == 'dotnet' ? {
    DOTNET_VERSION: runtimeVersion
  } : {},
  appSettings)
}

@description('The resource ID of the function app.')
output functionAppId string = functionApp.id

@description('The name of the function app.')
output functionAppName string = functionApp.name

@description('The default host name of the function app.')
output defaultHostName string = functionApp.properties.defaultHostName

@description('The resource ID of the app service plan.')
output appServicePlanId string = appServicePlan.id

@description('The name of the app service plan.')
output appServicePlanName string = appServicePlan.name