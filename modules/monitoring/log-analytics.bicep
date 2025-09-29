@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the Log Analytics workspace.')
param workspaceName string

@description('The pricing tier (Per GB or PerNode).')
@allowed(['PerGB2018', 'PerNode', 'Premium', 'Standard', 'Standalone', 'Unlimited', 'CapacityReservation'])
param sku string = 'PerGB2018'

@description('The workspace data retention in days.')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('The network access type for accessing Log Analytics ingestion.')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('The network access type for accessing Log Analytics query.')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccessForQuery string = 'Enabled'

@description('The capacity reservation level for this workspace, when CapacityReservation sku is selected.')
@allowed([100, 200, 300, 400, 500, 1000, 2000, 5000])
param capacityReservationLevel int = 100

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: sku
      capacityReservationLevel: sku == 'CapacityReservation' ? capacityReservationLevel : null
    }
    retentionInDays: retentionInDays
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
  }
}

@description('The resource ID of the Log Analytics workspace.')
output workspaceId string = logAnalyticsWorkspace.id

@description('The name of the Log Analytics workspace.')
output workspaceName string = logAnalyticsWorkspace.name

@description('The customer ID of the Log Analytics workspace.')
output customerId string = logAnalyticsWorkspace.properties.customerId