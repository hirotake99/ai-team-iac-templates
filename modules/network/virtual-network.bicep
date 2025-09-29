@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the virtual network.')
param virtualNetworkName string

@description('The address prefix for the virtual network.')
param addressPrefix string = '10.0.0.0/16'

@description('Array of subnet configurations.')
param subnets array = [
  {
    name: 'default'
    addressPrefix: '10.0.1.0/24'
  }
]

@description('Indicates whether DDoS protection is enabled.')
param enableDdosProtection bool = false

@description('The resource ID of the DDoS protection plan.')
param ddosProtectionPlanId string = ''

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: contains(subnet, 'networkSecurityGroupId') ? {
          id: subnet.networkSecurityGroupId
        } : null
        routeTable: contains(subnet, 'routeTableId') ? {
          id: subnet.routeTableId
        } : null
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
        delegations: contains(subnet, 'delegations') ? subnet.delegations : []
      }
    }]
    enableDdosProtection: enableDdosProtection
    ddosProtectionPlan: enableDdosProtection && !empty(ddosProtectionPlanId) ? {
      id: ddosProtectionPlanId
    } : null
  }
}

@description('The resource ID of the virtual network.')
output virtualNetworkId string = virtualNetwork.id

@description('The name of the virtual network.')
output virtualNetworkName string = virtualNetwork.name

@description('The array of subnet resource IDs.')
output subnetIds array = [for (subnet, i) in subnets: {
  name: subnet.name
  id: virtualNetwork.properties.subnets[i].id
}]