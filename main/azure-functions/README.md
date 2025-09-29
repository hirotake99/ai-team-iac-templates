# Azure Functions デプロイ

このテンプレートは Azure Functions アプリケーションとその依存リソースを一括デプロイするためのものです。

## 📦 作成されるリソース

- **Azure Functions App**: サーバーレス関数実行環境
- **App Service Plan**: 関数アプリのホスティングプラン
- **Storage Account**: 関数アプリの状態管理用ストレージ
- **Application Insights**: 監視・ログ収集サービス
- **リソースグループタグ**: プロジェクト管理用タグ

## 🔧 パラメータ

| パラメータ名 | 説明 | デフォルト値 | 選択肢 |
|-------------|------|-------------|--------|
| `location` | デプロイ先リージョン | `resourceGroup().location` | - |
| `functionAppName` | 関数アプリ名 | `func-{uniqueString}` | - |
| `appServicePlanName` | App Service Plan名 | `plan-{uniqueString}` | - |
| `appServicePlanSkuName` | App Service Plan SKU | `Y1` | `Y1`, `EP1`, `EP2`, `EP3`, `P1V2`, `P2V2`, `P3V2` |
| `appServicePlanSkuTier` | App Service Plan ティア | `Dynamic` | `Dynamic`, `ElasticPremium`, `PremiumV2` |
| `runtime` | ランタイムスタック | `node` | `dotnet`, `java`, `node`, `python`, `powershell` |
| `runtimeVersion` | ランタイムバージョン | `18` | ランタイムによる |
| `storageAccountName` | ストレージアカウント名 | `stor{uniqueString}` | - |
| `storageAccountSku` | ストレージアカウントSKU | `Standard_LRS` | `Standard_LRS`, `Standard_GRS`, `Standard_ZRS` |
| `applicationInsightsName` | Application Insights名 | `appi-{uniqueString}` | - |
| `httpsOnly` | HTTPS専用 | `true` | `true`, `false` |
| `alwaysOn` | Always On機能 | `false` | `true`, `false` |
| `appSettings` | カスタムアプリ設定 | `{}` | - |
| `tags` | リソースタグ | デフォルトタグ | - |

## 🚀 デプロイ方法

### 基本デプロイ（Node.js、Consumption Plan）

```bash
az deployment group create \
  --resource-group your-resource-group \
  --template-file main/azure-functions/main.bicep
```

### ランタイム指定デプロイ

```bash
# Python 3.9 でデプロイ
az deployment group create \
  --resource-group your-resource-group \
  --template-file main/azure-functions/main.bicep \
  --parameters runtime=python runtimeVersion=3.9

# .NET 6 でデプロイ
az deployment group create \
  --resource-group your-resource-group \
  --template-file main/azure-functions/main.bicep \
  --parameters runtime=dotnet runtimeVersion=6
```

### Premium Plan でデプロイ

```bash
az deployment group create \
  --resource-group your-resource-group \
  --template-file main/azure-functions/main.bicep \
  --parameters \
    appServicePlanSkuName=EP1 \
    appServicePlanSkuTier=ElasticPremium \
    alwaysOn=true
```

### カスタムアプリ設定付きデプロイ

```bash
az deployment group create \
  --resource-group your-resource-group \
  --template-file main/azure-functions/main.bicep \
  --parameters \
    functionAppName=myapp-func \
    appSettings='{"CUSTOM_SETTING":"value","API_KEY":"your-api-key"}'
```

## 📋 ホスティングプラン比較

| プラン | SKU | 説明 | 用途 |
|--------|-----|------|------|
| Consumption | Y1 | 使用量ベース課金、自動スケール | 開発・軽量ワークロード |
| Premium | EP1/EP2/EP3 | 予約インスタンス、VNet統合 | 本番環境・高性能要件 |
| Dedicated | P1V2/P2V2/P3V2 | 専用インスタンス | 予測可能なコスト |

## 🔧 ランタイム別設定

### Node.js
- サポートバージョン: `14`, `16`, `18`, `20`
- パッケージ管理: npm, yarn
- デプロイ: ZIP、Git、DevOps

### Python
- サポートバージョン: `3.8`, `3.9`, `3.10`, `3.11`
- パッケージ管理: pip, poetry
- Linux 専用

### .NET
- サポートバージョン: `6`, `8`
- 言語: C#, F#, VB.NET
- 高性能・型安全

### Java
- サポートバージョン: `8`, `11`, `17`
- ビルドツール: Maven, Gradle
- エンタープライズ向け

### PowerShell
- サポートバージョン: `7.0`, `7.2`
- Windows 管理タスク
- Azure 自動化

## 🚀 デプロイ後の操作

### 関数コードのデプロイ

```bash
# Azure Functions Core Tools を使用
func azure functionapp publish your-function-app-name

# ZIP デプロイ
az functionapp deployment source config-zip \
  --resource-group your-resource-group \
  --name your-function-app-name \
  --src function-app.zip
```

### ログの確認

```bash
# リアルタイムログストリーミング
az webapp log tail --name your-function-app-name --resource-group your-resource-group

# Application Insights でのクエリ
az monitor app-insights query \
  --app your-app-insights-name \
  --analytics-query "requests | limit 10"
```

### 設定の更新

```bash
# アプリ設定の追加
az functionapp config appsettings set \
  --name your-function-app-name \
  --resource-group your-resource-group \
  --settings "NEW_SETTING=value"
```

## ⚠️ 注意事項

### セキュリティ
- 本番環境では `httpsOnly: true` を設定
- 機密情報は Key Vault を使用
- 認証・認可の設定を推奨

### パフォーマンス
- Premium Plan では `alwaysOn: true` を設定
- Application Insights でパフォーマンス監視
- 適切なタイムアウト設定

### コスト最適化
- Consumption Plan は使用量ベース課金
- 不要な Always On 設定の回避
- ストレージコストの監視

### 制限事項
- Consumption Plan: 実行時間10分まで
- メモリ使用量の制限
- 同時実行数の制限

## 🔌 統合例

### Event Grid との統合

```bash
# イベントサブスクリプション作成
az eventgrid event-subscription create \
  --name myeventsubscription \
  --source-resource-id "/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{storage}" \
  --endpoint "https://your-function-app.azurewebsites.net/api/your-function"
```

### Service Bus との統合

```json
{
  "bindings": [
    {
      "name": "msg",
      "type": "serviceBusTrigger",
      "direction": "in",
      "topicName": "mytopic",
      "subscriptionName": "mysubscription",
      "connection": "ServiceBusConnection"
    }
  ]
}
```

## 📤 出力値

デプロイ完了後、以下の値が出力されます：

- `functionAppId`: Function App のリソースID
- `functionAppName`: Function App 名
- `functionAppUrl`: Function App のURL
- `storageAccountId`: ストレージアカウントのリソースID
- `storageAccountName`: ストレージアカウント名
- `applicationInsightsId`: Application Insights のリソースID
- `applicationInsightsName`: Application Insights 名

これらの値は他のリソースから参照可能です。