// =============================================================================
// フェーズ 1: パラメータ定義
// 環境間でテンプレートを再利用可能にするための入力パラメータを定義
// =============================================================================

@description('The name of the Azure Function app.')
param functionAppName string = 'func-${uniqueString(resourceGroup().id)}'

@description('Location for all modules.')
param location string = resourceGroup().location

@description('Location for Application Insights')
param appInsightsLocation string = resourceGroup().location

@description('The language worker runtime to load in the function app.')
@allowed([
  'dotnet'
  'node'
  'python'
  'java'
])
param functionWorkerRuntime string = 'node'

@description('Required for Linux app to represent runtime stack in the format of \'runtime|runtimeVersion\'. For example: \'python|3.9\'')
param linuxFxVersion string

@description('The zip content url.')
param packageUri string

// =============================================================================
// フェーズ 2: 変数定義
// リソースの計算値と命名規則を定義
// =============================================================================

var hostingPlanName = functionAppName
var applicationInsightsName = functionAppName
var storageAccountName = '${uniqueString(resourceGroup().id)}azfunctions'

// =============================================================================
// フェーズ 3: 基盤インフラストラクチャ（依存関係なし）
// 他のコンポーネントが依存する基盤リソースをデプロイ
// =============================================================================

// Storage Account - Function Appとファイル共有のためのバックエンドストレージを提供
module storageAccount '../../modules/storage/storage-account.bicep' = {
  name: 'storageAccount'
  params: {
    storageAccountName: storageAccountName
    location: location
  }
}

module applicationInsights '../../modules/monitoring/application-insights.bicep' = {
  name: 'applicationInsights'
  params: {
    applicationInsightsName: applicationInsightsName
    location: appInsightsLocation
    functionAppName: functionAppName
  }
}


// App Service Plan - Function Appのホスティング環境を提供
module hostingPlan '../../modules/compute/app-service-plan.bicep' = {
  name: 'hostingPlan'
  params: {
    hostingPlanName: hostingPlanName
    location: location
  }
}

// Function App - すべての基盤リソースに依存するメインアプリケーションコンポーネント
module functionApp '../../modules/compute/function-app.bicep' = {
  name: 'functionApp'
  params: {
    functionAppName: functionAppName
    location: location
    functionWorkerRuntime: functionWorkerRuntime
    linuxFxVersion: linuxFxVersion
    packageUri: packageUri
    hostingPlanId: hostingPlan.outputs.hostingPlanId
    storageAccountName: storageAccountName
    storageAccountKey: storageAccount.outputs.storageAccountPrimaryKey
    instrumentationKey: applicationInsights.outputs.instrumentationKey
  }
}
