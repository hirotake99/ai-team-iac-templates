# AI Team IaC Templates 🚀

Azure Bicepを使用したAIチーム共通のInfrastructure as Codeテンプレート集です。

## 📋 概要

このリポジトリは、AIチームのプロジェクトで使用する標準化されたAzureリソースのデプロイテンプレートを提供します。

## 🚀 クイックスタート

### 前提条件
- Azure CLI (2.40.0以上)
- Bicep CLI (0.22.0以上)
- Azure サブスクリプション

### 基本的な使用方法

```bash
# 開発環境のデプロイ
az deployment sub create \
  --location japaneast \
  --template-file templates/ml-training-env/main.bicep \
  --parameters templates/ml-training-env/parameters.dev.json
```

詳細は[デプロイメントガイド](./docs/deployment-guide.md)を参照してください。
