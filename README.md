# AI Team IaC Templates

このリポジトリには、AIチーム向けのAzure Infrastructure as Code (IaC) テンプレートが含まれています。

## 🎯 リポジトリの方針

このリポジトリは、**AIチームが案件で再利用できるインフラ設定を随時追加していく**ことを目的としています。

- **継続的な拡張**: 新しい案件で使用したインフラ構成は積極的にテンプレート化
- **チーム共有**: 個人の知見をチーム全体で活用できる形で蓄積
- **標準化**: 統一されたベストプラクティスによる品質向上
- **効率化**: 類似案件での開発時間短縮とデプロイ作業の簡素化

## 📁 プロジェクト構成

```
ai-team-iac-templates/
├── modules/                          # 再利用可能なBicepモジュール
│   ├── compute/                      # コンピューティングリソース
│   ├── container/                    # コンテナリソース
│   ├── data/                         # データリソース
│   ├── monitoring/                   # 監視・ログリソース
│   ├── network/                      # ネットワークリソース
│   ├── security/                     # セキュリティリソース
│   ├── storage/                      # ストレージリソース
│   └── web/                          # Webアプリケーションリソース
├── main/                             # デプロイ用メインテンプレート
│   ├── container-registry/           # ACRデプロイ用
│   │   ├── main.bicep               # デプロイテンプレート
│   │   └── README.md                # デプロイ手順・詳細情報
│   └── azure-functions/             # Azure Functionsデプロイ用
│       ├── main.bicep               # デプロイテンプレート
│       └── README.md                # デプロイ手順・詳細情報
└── README.md                        # このファイル
```

## 📂 ディレクトリの説明

### modules/ ディレクトリ
**目的**: 再利用可能なBicepモジュールライブラリ
- **構成**: Azure リソース種別ごとにフォルダ分類
- **用途**: main テンプレートから参照される基本構成要素
- **特徴**:
  - 単一リソースまたは関連リソースグループの定義
  - パラメータ化された柔軟な設計
  - 複数のプロジェクトで再利用可能

### main/ ディレクトリ
**目的**: 実際のデプロイに使用するテンプレート集
- **構成**: 目的別サブディレクトリ、各々に `main.bicep` と `README.md`
- **命名規則**: サブディレクトリ名は一目でデプロイ内容がわかる名前（例：`container-registry`, `azure-functions`, `web-app`, `database`）
- **用途**: プロダクション環境での直接デプロイ
- **特徴**:
  - modules の組み合わせによる完全なソリューション
  - 目的特化型（ACR、Functions等）
  - デプロイ手順とパラメータ詳細をREADMEで提供

## 🔄 開発フロー

### 新しいテンプレート追加時の手順
1. 新しいリソースが必要な場合、まず `modules/{リソース種別}/` にモジュールを作成
2. `main/{目的}/` フォルダを作成（フォルダ名は「何をデプロイするか」が一目でわかる名前にする）
3. `main/{目的}/main.bicep` でモジュールを組み合わせてデプロイテンプレートを作成
4. `main/{目的}/README.md` でデプロイ手順と詳細情報を記載
5. 実際のデプロイは `main` ディレクトリのテンプレートを使用

### サブディレクトリ命名例
| フォルダ名 | デプロイ内容 | 説明 |
|-----------|-------------|------|
| `container-registry` | Azure Container Registry | プライベートDockerレジストリ |
| `azure-functions` | Azure Functions アプリ | サーバーレス関数実行環境 |
| `web-app` | Web アプリケーション | App Service Web Apps |
| `database` | データベース関連 | SQL Database, Cosmos DB等 |
| `api-management` | API Management | API ゲートウェイ・管理 |
| `storage` | ストレージソリューション | Storage Account, File Share等 |
| `monitoring` | 監視・ログ | Application Insights, Log Analytics等 |

### 📈 テンプレート追加の推奨タイミング
- 新しい案件で特定のインフラ構成を構築した時
- 既存テンプレートの改良版や最適化版を作成した時
- AIプロジェクトで頻繁に使用されるパターンを発見した時
- セキュリティやコンプライアンス要件に対応した構成を作成した時

## 🚀 デプロイ手順

### 前提条件

1. **Azure CLI のインストール**
   ```bash
   # macOS
   brew install azure-cli

   # Windows
   winget install Microsoft.AzureCLI

   # Ubuntu/Debian
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

2. **Bicep CLI のインストール**
   ```bash
   az bicep install
   az bicep upgrade
   ```

3. **Azureにログイン**
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

### リソースグループの準備

```bash
# リソースグループを作成
az group create --name iac-templates-group --location japaneast
```

## 🚀 基本的なデプロイ手順

### 1. モジュール単体でのデプロイ

個別のBicepモジュールを直接デプロイできます：

```bash
# ストレージアカウントをデプロイ
az deployment group create \
  --resource-group your-resource-group \
  --template-file modules/storage/storage-account.bicep \
  --parameters storageAccountName=mystorageaccount

# Key Vaultをデプロイ
az deployment group create \
  --resource-group your-resource-group \
  --template-file modules/security/key-vault.bicep \
  --parameters keyVaultName=mykeyvault

# Virtual Networkをデプロイ
az deployment group create \
  --resource-group your-resource-group \
  --template-file modules/network/virtual-network.bicep \
  --parameters virtualNetworkName=myvnet
```

### 2. メインテンプレートでのデプロイ

複数リソースを組み合わせたテンプレートを使用：

```bash
# 既存のメインテンプレートを使用
az deployment group create \
  --resource-group your-resource-group \
  --template-file main/deploy-function-app.bicep

# パラメータをカスタマイズ
az deployment group create \
  --resource-group your-resource-group \
  --template-file main/deploy-acr.bicep \
  --parameters registryName=myregistry sku=Premium
```

### 3. カスタムメインテンプレートの作成

独自のメインテンプレートを作成して必要なモジュールを組み合わせ：

```bash
# カスタムテンプレートをデプロイ
az deployment group create \
  --resource-group your-resource-group \
  --template-file your-custom-main.bicep \
  --parameters @your-parameters.json
```

### 📋 デプロイ時の共通パラメータ

| パラメータ | 説明 | 例 |
|-----------|------|-----|
| `location` | デプロイ先リージョン | `japaneast`, `eastus` |
| `--resource-group` | リソースグループ名 | `my-project-rg` |
| `--parameters` | パラメータ指定 | `key=value` または `@file.json` |
| `--name` | デプロイ名 | 指定しない場合は自動生成 |

## 🔧 カスタムメインテンプレートの作成

### 基本的なテンプレート構造

独自のメインテンプレートを作成してモジュールを組み合わせ：

```bicep
// custom-main.bicep の例
targetScope = 'resourceGroup'

@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('Environment name (dev, test, prod)')
param environment string = 'dev'

@description('Project name for resource naming')
param projectName string

// Variables
var resourceSuffix = '${projectName}-${environment}-${uniqueString(resourceGroup().id)}'

// Storage Account
module storage 'modules/storage/storage-account.bicep' = {
  name: 'storageAccount'
  params: {
    location: location
    storageAccountName: 'stor${replace(resourceSuffix, '-', '')}'
    skuName: 'Standard_LRS'
  }
}

// Key Vault
module keyVault 'modules/security/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    keyVaultName: 'kv-${resourceSuffix}'
    skuName: 'standard'
  }
}

// Virtual Network
module virtualNetwork 'modules/network/virtual-network.bicep' = {
  name: 'virtualNetwork'
  params: {
    location: location
    virtualNetworkName: 'vnet-${resourceSuffix}'
    addressPrefix: '10.0.0.0/16'
  }
}

// Outputs
output storageAccountName string = storage.outputs.storageAccountName
output keyVaultName string = keyVault.outputs.keyVaultName
output virtualNetworkId string = virtualNetwork.outputs.virtualNetworkId
```

### パラメータファイルの作成

```json
// parameters.json の例
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "location": {
      "value": "japaneast"
    },
    "environment": {
      "value": "dev"
    },
    "projectName": {
      "value": "myproject"
    }
  }
}
```

### デプロイ実行例

```bash
# カスタムテンプレートとパラメータファイルを使ってデプロイ
az deployment group create \
  --resource-group my-project-rg \
  --template-file custom-main.bicep \
  --parameters @parameters.json

# インラインパラメータでデプロイ
az deployment group create \
  --resource-group my-project-rg \
  --template-file custom-main.bicep \
  --parameters location=japaneast environment=prod projectName=webapp
```

## ⚠️ トラブルシューティング

### よくある問題と解決策

#### 1. クォータ制限エラー

```
ERROR: Quota exceeded for : 0 VMs allowed, 1 VMs requested
```

**解決策:**
1. **別リージョンを試す**
   ```bash
   --parameters location=eastus
   ```

2. **Azure サポートでクォータ増加を要求**
   - Azure ポータル → ヘルプ + サポート → 新しいサポート リクエスト
   - 問題の種類: `サービスとサブスクリプションの制限 (クォータ)`

3. **不要なリソースを削除**
   ```bash
   az resource list --query "[?resourceGroup=='old-rg']" --output table
   az group delete --name old-resource-group --yes --no-wait
   ```

#### 2. ストレージアカウント名の競合

```
ERROR: Storage account name 'stor...' is already taken
```

**解決策:**
```bash
# 一意な名前を指定
--parameters storageAccountName=mystorage$(date +%s)
```

#### 3. 権限エラー

```
ERROR: The client does not have authorization to perform action
```

**解決策:**
```bash
# 適切なロールを確認
az role assignment list --assignee $(az account show --query user.name -o tsv) --output table

# 必要に応じて権限を付与（サブスクリプション管理者による）
az role assignment create --assignee user@domain.com --role "Contributor"
```



## 📞 サポート

問題や質問がある場合：
- Issue を作成
- [Azure Documentation](https://docs.microsoft.com/azure/) を参照
- [Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/) を確認