# Azure Monitor Alert を Teams へ投稿する

## Logic App Workflows

Logic App Workflows をデプロイする

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fokumura-pico%2Fted-blog-resources%2Fmain%2Flogic-app-post-teams%2Ftemplate.json)

### パラメータ

| パラメータ        | 説明                       |
| :---------------- | :------------------------- |
| location          | デプロイ先リージョン       |
| workflows_name    | Logic App Workflows の名前 |
| teams_webhook_url | POST 先 WebHook URL        |

