@description('App Service Plan（ホスティングプラン）の名前')
param hostingPlanName string

@description('App Service Planのロケーション')
param location string = resourceGroup().location

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
  }
  properties: {
    reserved: true
  }
}

output hostingPlanId string = hostingPlan.id
output hostingPlanName string = hostingPlan.name