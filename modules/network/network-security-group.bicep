@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the network security group.')
param networkSecurityGroupName string

@description('Array of security rules.')
param securityRules array = []

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [for rule in securityRules: {
      name: rule.name
      properties: {
        description: contains(rule, 'description') ? rule.description : null
        protocol: rule.protocol
        sourcePortRange: contains(rule, 'sourcePortRange') ? rule.sourcePortRange : null
        sourcePortRanges: contains(rule, 'sourcePortRanges') ? rule.sourcePortRanges : null
        destinationPortRange: contains(rule, 'destinationPortRange') ? rule.destinationPortRange : null
        destinationPortRanges: contains(rule, 'destinationPortRanges') ? rule.destinationPortRanges : null
        sourceAddressPrefix: contains(rule, 'sourceAddressPrefix') ? rule.sourceAddressPrefix : null
        sourceAddressPrefixes: contains(rule, 'sourceAddressPrefixes') ? rule.sourceAddressPrefixes : null
        destinationAddressPrefix: contains(rule, 'destinationAddressPrefix') ? rule.destinationAddressPrefix : null
        destinationAddressPrefixes: contains(rule, 'destinationAddressPrefixes') ? rule.destinationAddressPrefixes : null
        access: rule.access
        priority: rule.priority
        direction: rule.direction
      }
    }]
  }
}

@description('The resource ID of the network security group.')
output networkSecurityGroupId string = networkSecurityGroup.id

@description('The name of the network security group.')
output networkSecurityGroupName string = networkSecurityGroup.name