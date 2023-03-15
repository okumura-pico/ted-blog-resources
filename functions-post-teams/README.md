# Azure Monitor Alert を Teams へ投稿する

## 作成リソース

- Storage Account
- App Service Plan
- Azure Function App

## Azure Function App

Azure Function App をデプロイする

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fokumura-pico%2Fted-blog-resources%2Fmain%2Ffunctions-post-teams%2Ftemplate.json)

### パラメータ

設定するパラメータ(抜粋)です。

| パラメータ          | 説明                                                          |
| :------------------ | :------------------------------------------------------------ |
| location            | デプロイ先リージョン                                          |
| functionAppName     | Azure Funcion App の名前                                      |
| TEAMS_WEBHOOK_URL   | Teams に設定した WebHook コネクタの URL                       |
| AZURE_API_VERSION   | Function App 内で使用している Azure API のバージョン          |
| AZURE_CLIENT_ID     | Azure リソース取得に使用するアプリケーションのクライアント ID |
| AZURE_CLIENT_SECRET | アプリケーションのシークレット                                |
| AZURE_TENANT_ID     | アプリケーションが存在するテナント ID                         |
