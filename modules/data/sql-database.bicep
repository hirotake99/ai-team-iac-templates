@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the SQL server.')
param sqlServerName string

@description('The administrator username of the SQL server.')
param administratorLogin string

@description('The administrator password of the SQL server.')
@secure()
param administratorLoginPassword string

@description('The name of the SQL database.')
param databaseName string

@description('The SKU name of the database.')
param databaseSkuName string = 'Basic'

@description('The tier of the database SKU.')
param databaseSkuTier string = 'Basic'

@description('The capacity of the database SKU.')
param databaseSkuCapacity int = 5

@description('The maximum size of the database in bytes.')
param maxSizeBytes int = 2147483648

@description('Specifies whether Azure services can access the server.')
param allowAzureIps bool = true

@description('The minimum TLS version for the server.')
@allowed(['1.0', '1.1', '1.2'])
param minimalTlsVersion string = '1.2'

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    minimalTlsVersion: minimalTlsVersion
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: databaseSkuName
    tier: databaseSkuTier
    capacity: databaseSkuCapacity
  }
  properties: {
    maxSizeBytes: maxSizeBytes
  }
}

resource allowAzureIpsFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = if (allowAzureIps) {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

@description('The resource ID of the SQL server.')
output sqlServerId string = sqlServer.id

@description('The name of the SQL server.')
output sqlServerName string = sqlServer.name

@description('The fully qualified domain name of the SQL server.')
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName

@description('The resource ID of the SQL database.')
output sqlDatabaseId string = sqlDatabase.id

@description('The name of the SQL database.')
output sqlDatabaseName string = sqlDatabase.name