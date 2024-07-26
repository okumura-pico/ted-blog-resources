# 日本語化 Windows 11 イメージビルダー

AVD 用のマスタイメージをビルドします。

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fokumura-pico%2Fted-blog-resources%2Fmain%2Fwindows-11-ja-image%2Fwindows-11-ja-image.json)

## 🏢 ビルド方法

bicep ファイルから始める場合

```console
az deployment group create -g リソースグループ名 --template-file windows-11-ja-image.bicep
```

作成されたイメージテンプレートを開き、ビルドを実行します。

## 🌳 含まれている Azure リソース

- カスタムロール
- マネージドアイデンティティ
- イメージギャラリー
- イメージテンプレート

## 📓 ノート

- イメージテンプレートの更新はサポートされていないので、再デプロイするときは先に削除する必要があります。
- ログファイルが自動作成されたストレージアカウントに出力されます。ストレージアカウントは、*IT-*で始まるリソースグループにあります。
