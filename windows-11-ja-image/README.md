# 日本語化 Windows 11 イメージビルダー

AVD 用のマスタイメージをビルドします。

## Getting started

```console
az deployment group create -g リソースグループ名 --template-file windows-11-ja-image.bicep
```

作成されたイメージテンプレートを開き、ビルドを実行します。

## 含まれている Azure リソース

- カスタムロール
- マネージドアイデンティティ
- イメージギャラリー
- イメージテンプレート

## ノート

- イメージテンプレートの更新はサポートされていないので、再デプロイするときは先に削除する必要があります。
