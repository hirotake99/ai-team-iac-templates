@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the network interface.')
param networkInterfaceName string

@description('The resource ID of the subnet.')
param subnetId string

@description('The resource ID of the public IP address (optional).')
param publicIpId string = ''

@description('The resource ID of the network security group (optional).')
param networkSecurityGroupId string = ''

@description('The private IP allocation method.')
@allowed(['Dynamic', 'Static'])
param privateIPAllocationMethod string = 'Dynamic'

@description('The static private IP address (required if allocation method is Static).')
param staticPrivateIPAddress string = ''

@description('Enable IP forwarding.')
param enableIPForwarding bool = false

@description('Enable accelerated networking.')
param enableAcceleratedNetworking bool = false

@description('Array of additional IP configurations.')
param additionalIpConfigurations array = []

@description('The primary DNS server IP address.')
param primaryDnsServer string = ''

@description('The secondary DNS server IP address.')
param secondaryDnsServer string = ''

resource networkInterface 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: concat([
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
          privateIPAddress: privateIPAllocationMethod == 'Static' ? staticPrivateIPAddress : null
          subnet: {
            id: subnetId
          }
          publicIPAddress: !empty(publicIpId) ? {
            id: publicIpId
          } : null
          primary: true
        }
      }
    ], [for (config, i) in additionalIpConfigurations: {
      name: 'ipconfig${i + 2}'
      properties: {
        privateIPAllocationMethod: config.privateIPAllocationMethod
        privateIPAddress: config.privateIPAllocationMethod == 'Static' ? config.staticPrivateIPAddress : null
        subnet: {
          id: config.subnetId
        }
        publicIPAddress: contains(config, 'publicIpId') && !empty(config.publicIpId) ? {
          id: config.publicIpId
        } : null
        primary: false
      }
    }])
    networkSecurityGroup: !empty(networkSecurityGroupId) ? {
      id: networkSecurityGroupId
    } : null
    enableIPForwarding: enableIPForwarding
    enableAcceleratedNetworking: enableAcceleratedNetworking
    dnsSettings: !empty(primaryDnsServer) ? {
      dnsServers: !empty(secondaryDnsServer) ? [
        primaryDnsServer
        secondaryDnsServer
      ] : [
        primaryDnsServer
      ]
    } : null
  }
}

@description('The resource ID of the network interface.')
output networkInterfaceId string = networkInterface.id

@description('The name of the network interface.')
output networkInterfaceName string = networkInterface.name

@description('The private IP address of the primary IP configuration.')
output privateIPAddress string = networkInterface.properties.ipConfigurations[0].properties.privateIPAddress

@description('The MAC address of the network interface.')
output macAddress string = networkInterface.properties.macAddress