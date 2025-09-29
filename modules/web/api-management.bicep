@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the API Management service.')
param apiManagementName string

@description('The SKU of the API Management service.')
@allowed(['Developer', 'Basic', 'Standard', 'Premium', 'Consumption'])
param sku string = 'Developer'

@description('The instance size of the API Management service.')
param skuCount int = 1

@description('The email address of the publisher/company.')
param publisherEmail string

@description('The name of the publisher/company.')
param publisherName string

@description('Enable zone redundancy for Premium SKU.')
param enableZoneRedundancy bool = false

@description('Virtual network configuration.')
param virtualNetworkConfiguration object = {}

@description('Virtual network type.')
@allowed(['None', 'External', 'Internal'])
param virtualNetworkType string = 'None'

@description('Enable client certificate authentication.')
param enableClientCertificate bool = false

resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: apiManagementName
  location: location
  sku: {
    name: sku
    capacity: sku == 'Consumption' ? 0 : skuCount
  }
  zones: sku == 'Premium' && enableZoneRedundancy ? ['1', '2', '3'] : null
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: !empty(virtualNetworkConfiguration) ? virtualNetworkConfiguration : null
    customProperties: sku == 'Consumption' ? {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'false'
    } : {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'false'
    }
    enableClientCertificate: enableClientCertificate
  }
}

@description('The resource ID of the API Management service.')
output apiManagementId string = apiManagement.id

@description('The name of the API Management service.')
output apiManagementName string = apiManagement.name

@description('The gateway URL of the API Management service.')
output gatewayUrl string = apiManagement.properties.gatewayUrl

@description('The management API URL of the API Management service.')
output managementApiUrl string = apiManagement.properties.managementApiUrl

@description('The portal URL of the API Management service.')
output portalUrl string = apiManagement.properties.portalUrl