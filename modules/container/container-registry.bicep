@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the container registry.')
param registryName string

@description('The SKU of the container registry.')
@allowed(['Basic', 'Standard', 'Premium'])
param sku string = 'Basic'

@description('Enable admin user for the container registry.')
param adminUserEnabled bool = false

@description('Whether to allow public network access.')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Enabled'

@description('The network rule set for the container registry.')
param networkRuleSet object = {}

@description('Enable zone redundancy for Premium SKU.')
param zoneRedundancy bool = false

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: registryName
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: publicNetworkAccess
    networkRuleSet: !empty(networkRuleSet) ? networkRuleSet : null
    zoneRedundancy: sku == 'Premium' ? (zoneRedundancy ? 'Enabled' : 'Disabled') : null
  }
}

@description('The resource ID of the container registry.')
output registryId string = containerRegistry.id

@description('The name of the container registry.')
output registryName string = containerRegistry.name

@description('The login server URL of the container registry.')
output loginServer string = containerRegistry.properties.loginServer

