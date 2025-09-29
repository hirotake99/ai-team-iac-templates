@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the Application Insights component.')
param applicationInsightsName string

@description('The type of application being monitored.')
@allowed(['web', 'other'])
param applicationType string = 'web'

@description('The resource ID of the Log Analytics workspace (optional).')
param workspaceResourceId string = ''

@description('The data retention period in days.')
@minValue(30)
@maxValue(730)
param retentionInDays int = 90


@description('Disable IP masking.')
param disableIpMasking bool = false

@description('Disable local authentication.')
param disableLocalAuth bool = false

@description('Force customer storage for profiler.')
param forceCustomerStorageForProfiler bool = false

@description('Immediately purge data on 30 days.')
param immediatePurgeDataOn30Days bool = true

@description('The network access type for ingestion.')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('The network access type for query.')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccessForQuery string = 'Enabled'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: applicationType
  properties: {
    Application_Type: applicationType
    WorkspaceResourceId: !empty(workspaceResourceId) ? workspaceResourceId : null
    RetentionInDays: retentionInDays
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    DisableIpMasking: disableIpMasking
    DisableLocalAuth: disableLocalAuth
    ForceCustomerStorageForProfiler: forceCustomerStorageForProfiler
    ImmediatePurgeDataOn30Days: immediatePurgeDataOn30Days
  }
}


@description('The resource ID of the Application Insights component.')
output applicationInsightsId string = applicationInsights.id

@description('The name of the Application Insights component.')
output applicationInsightsName string = applicationInsights.name

@description('The instrumentation key of the Application Insights component.')
output instrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('The connection string of the Application Insights component.')
output connectionString string = applicationInsights.properties.ConnectionString