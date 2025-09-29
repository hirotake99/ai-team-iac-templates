@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the load balancer.')
param loadBalancerName string

@description('The SKU of the load balancer.')
@allowed(['Basic', 'Standard', 'Gateway'])
param sku string = 'Standard'

@description('The type of the load balancer.')
@allowed(['Internal', 'Public'])
param type string = 'Public'

@description('The name of the public IP address (required for public load balancer).')
param publicIpName string = ''

@description('The resource ID of the subnet (required for internal load balancer).')
param subnetId string = ''

@description('The private IP address (for internal load balancer).')
param privateIpAddress string = ''

@description('Array of backend pools.')
param backendPools array = []

@description('Array of load balancing rules.')
param loadBalancingRules array = []

@description('Array of health probes.')
param healthProbes array = []

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-01-01' = if (type == 'Public' && !empty(publicIpName)) {
  name: publicIpName
  location: location
  sku: {
    name: sku == 'Basic' ? 'Basic' : 'Standard'
  }
  properties: {
    publicIPAllocationMethod: sku == 'Basic' ? 'Dynamic' : 'Static'
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2024-01-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name: sku
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'frontend'
        properties: type == 'Public' ? {
          publicIPAddress: {
            id: publicIp.id
          }
        } : {
          subnet: {
            id: subnetId
          }
          privateIPAddress: !empty(privateIpAddress) ? privateIpAddress : null
          privateIPAllocationMethod: !empty(privateIpAddress) ? 'Static' : 'Dynamic'
        }
      }
    ]
    backendAddressPools: [for pool in backendPools: {
      name: pool.name
    }]
    loadBalancingRules: [for rule in loadBalancingRules: {
      name: rule.name
      properties: {
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, 'frontend')
        }
        backendAddressPool: {
          id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, rule.backendPoolName)
        }
        probe: contains(rule, 'probeName') ? {
          id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, rule.probeName)
        } : null
        protocol: rule.protocol
        frontendPort: rule.frontendPort
        backendPort: rule.backendPort
        enableFloatingIP: contains(rule, 'enableFloatingIP') ? rule.enableFloatingIP : false
        idleTimeoutInMinutes: contains(rule, 'idleTimeoutInMinutes') ? rule.idleTimeoutInMinutes : 4
        loadDistribution: contains(rule, 'loadDistribution') ? rule.loadDistribution : 'Default'
      }
    }]
    probes: [for probe in healthProbes: {
      name: probe.name
      properties: {
        protocol: probe.protocol
        port: probe.port
        requestPath: probe.protocol == 'Http' || probe.protocol == 'Https' ? probe.requestPath : null
        intervalInSeconds: contains(probe, 'intervalInSeconds') ? probe.intervalInSeconds : 15
        numberOfProbes: contains(probe, 'numberOfProbes') ? probe.numberOfProbes : 2
      }
    }]
  }
}

@description('The resource ID of the load balancer.')
output loadBalancerId string = loadBalancer.id

@description('The name of the load balancer.')
output loadBalancerName string = loadBalancer.name

@description('The resource ID of the public IP (if public load balancer).')
output publicIpId string = type == 'Public' ? publicIp.id : ''

@description('The IP address of the load balancer.')
output ipAddress string = type == 'Public' ? publicIp.properties.ipAddress : privateIpAddress