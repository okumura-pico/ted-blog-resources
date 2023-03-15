@description('The name of the Azure Function app.')
param functionAppName string = 'func-${uniqueString(resourceGroup().name)}'

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Required for Linux app to represent runtime stack in the format of \'runtime|runtimeVersion\'. For example: \'node|18\'')
param linuxFxVersion string = 'node|18'

@description('The zip content url.')
param packageUri string = 'https://github.com/okumura-pico/azure-alert-to-teams-func/releases/download/latest/release.zip'

@description('Function App内で使用しているAzure APIのバージョン')
param AZURE_API_VERSION string = '2022-03-01'

@description('Azureリソース取得に使用するアプリケーションのクライアントID')
param AZURE_CLIENT_ID string

@description('アプリケーションのシークレット')
@secure()
param AZURE_CLIENT_SECRET string

@description('アプリケーションが存在するテナントID')
param AZURE_TENANT_ID string

var functionWorkerRuntime = 'node'
var hostingPlanName = functionAppName
var storageAccountName = 'func${uniqueString(resourceGroup().name)}stg'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
  }
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    reserved: true
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      appSettings: [
        {
          name: AZURE_API_VERSION
          value: AZURE_API_VERSION
        }
        { name: AZURE_CLIENT_ID
          value: AZURE_CLIENT_ID
        }
        {
          name: AZURE_CLIENT_SECRET
          value: AZURE_CLIENT_SECRET
        }
        {
          name: AZURE_TENANT_ID
          value: AZURE_TENANT_ID
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: packageUri
        }
      ]
    }
  }
}
