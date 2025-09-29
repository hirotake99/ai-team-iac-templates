# Azure Container Registry (ACR) デプロイ

このテンプレートは Azure Container Registry をデプロイするためのものです。

## 📦 作成されるリソース

- **Azure Container Registry**: プライベートDockerイメージレジストリ
- **リソースグループタグ**: プロジェクト管理用タグ

## 🔧 パラメータ

| パラメータ名 | 説明 | デフォルト値 | 選択肢 |
|-------------|------|-------------|--------|
| `location` | デプロイ先リージョン | `resourceGroup().location` | - |
| `registryName` | レジストリ名 | `myacr{uniqueString}` | - |
| `sku` | レジストリのSKU | `Standard` | `Basic`, `Standard`, `Premium` |
| `adminUserEnabled` | 管理者ユーザー有効化 | `true` | `true`, `false` |
| `publicNetworkAccess` | パブリックネットワークアクセス | `Enabled` | `Enabled`, `Disabled` |
| `networkRuleSet` | ネットワークルールセット | `{}` | - |
| `zoneRedundancy` | ゾーン冗長（Premium SKUのみ） | `false` | `true`, `false` |
| `tags` | リソースタグ | デフォルトタグ | - |

## 🚀 デプロイ方法

### 基本デプロイ

```bash
az deployment group create \
  --resource-group your-resource-group \
  --template-file main/container-registry/main.bicep
```

### パラメータ指定デプロイ

```bash
# Basic SKU でデプロイ
az deployment group create \
  --resource-group your-resource-group \
  --template-file main/container-registry/main.bicep \
  --parameters registryName=mycompanyacr sku=Basic

# Premium SKU、ゾーン冗長有効でデプロイ
az deployment group create \
  --resource-group your-resource-group \
  --template-file main/container-registry/main.bicep \
  --parameters \
    registryName=mycompanyacr \
    sku=Premium \
    zoneRedundancy=true
```

### プライベートエンドポイント設定例

```bash
# パブリックアクセス無効化
az deployment group create \
  --resource-group your-resource-group \
  --template-file main/container-registry/main.bicep \
  --parameters \
    registryName=mycompanyacr \
    sku=Premium \
    publicNetworkAccess=Disabled
```

## 📋 SKU 比較

| 機能 | Basic | Standard | Premium |
|------|-------|----------|---------|
| ストレージ | 10 GiB | 100 GiB | 500 GiB |
| 同時プッシュ/プル | 10 | 20 | 50 |
| Webhook | ✅ | ✅ | ✅ |
| Geo レプリケーション | ❌ | ❌ | ✅ |
| コンテンツの信頼性 | ❌ | ❌ | ✅ |
| プライベートエンドポイント | ❌ | ❌ | ✅ |
| VNet 統合 | ❌ | ❌ | ✅ |
| カスタマーマネージドキー | ❌ | ❌ | ✅ |

## 🔑 デプロイ後の操作

### 認証情報の取得

```bash
# 管理者ユーザーのパスワード取得
az acr credential show --name your-registry-name --resource-group your-resource-group

# Docker ログイン
az acr login --name your-registry-name
```

### イメージのプッシュ

```bash
# ローカルイメージにタグ付け
docker tag myapp:latest your-registry-name.azurecr.io/myapp:latest

# イメージをプッシュ
docker push your-registry-name.azurecr.io/myapp:latest
```

## ⚠️ 注意事項

### セキュリティ
- 本番環境では `adminUserEnabled` を `false` に設定し、Azure AD認証を使用することを推奨
- Premium SKU の場合はプライベートエンドポイントの使用を検討
- ネットワークアクセス制限の設定を推奨

### コスト最適化
- 開発環境では Basic SKU で十分
- 不要なイメージは定期的に削除
- Geo レプリケーションは必要な場合のみ有効化

### ネーミング規則
- レジストリ名は全世界で一意である必要があります
- 英数字のみ使用可能（ハイフンや特殊文字は使用不可）
- 5-50文字の制限があります

## 📤 出力値

デプロイ完了後、以下の値が出力されます：

- `registryId`: Container Registry のリソースID
- `registryName`: Container Registry 名
- `loginServer`: ログインサーバーURL

これらの値は他のリソースから参照可能です。