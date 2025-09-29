targetScope = 'resourceGroup'

@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The name of the container registry.')
param registryName string = 'myacr${uniqueString(resourceGroup().id)}'

@description('The SKU of the container registry.')
@allowed(['Basic', 'Standard', 'Premium'])
param sku string = 'Standard'

@description('Enable admin user for the container registry.')
param adminUserEnabled bool = true

@description('Whether to allow public network access.')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Enabled'

@description('The network rule set for the container registry.')
param networkRuleSet object = {}

@description('Enable zone redundancy for Premium SKU.')
param zoneRedundancy bool = false

@description('Tags to apply to the resources.')
param tags object = {
  environment: 'dev'
  project: 'ai-team'
  owner: 'devops-team'
}

module containerRegistry '../../modules/container/container-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    location: location
    registryName: registryName
    sku: sku
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: publicNetworkAccess
    networkRuleSet: networkRuleSet
    zoneRedundancy: zoneRedundancy
  }
}

resource resourceGroupTags 'Microsoft.Resources/tags@2022-09-01' = if (!empty(tags)) {
  name: 'default'
  properties: {
    tags: tags
  }
}

@description('The resource ID of the container registry.')
output registryId string = containerRegistry.outputs.registryId

@description('The name of the container registry.')
output registryName string = containerRegistry.outputs.registryName

@description('The login server URL of the container registry.')
output loginServer string = containerRegistry.outputs.loginServer
