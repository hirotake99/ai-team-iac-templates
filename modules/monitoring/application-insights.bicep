@description('Application Insightsコンポーネントの名前')
param applicationInsightsName string

@description('Application Insightsのロケーション')
param location string = resourceGroup().location

@description('リンクするFunction Appの名前（hidden linkタグ用）')
param functionAppName string

resource applicationInsight 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: {
    'hidden-link:${resourceId('Microsoft.Web/sites', functionAppName)}': 'Resource'
  }
  properties: {
    Application_Type: 'web'
  }
  kind: 'web'
}

output applicationInsightsId string = applicationInsight.id
output applicationInsightsName string = applicationInsight.name
output instrumentationKey string = applicationInsight.properties.InstrumentationKey