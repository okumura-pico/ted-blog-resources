@description('場所')
param location string = resourceGroup().location
@description('リソース名に前置する文字列')
param prefix string = 'avd'
@description('リソース名に後置する文字列')
param postfix string = uniqueString(resourceGroup().name)
@description('作成イメージの発行者')
param imagePublisher string = 'OurCompany'
@description('作成イメージのSKU')
param imageSku string = 'win11-23h2-avd-ja'
@description('作成イメージの名前')
param imageName string = 'Windows-11-ja'
param sourceImagePublisher string = 'MicrosoftWindowsDesktop'
param sourceImageOffer string = 'windows-11'
param sourceImageSku string = 'win11-23h2-avd'
param sourceImageVersion string = 'latest'

var roleName = '${prefix}-role-${postfix}'
var identityName = '${prefix}-id-${postfix}'
var galleryName = '${prefix}_gallery_${postfix}'
var imageTemplateName = '${prefix}-image-template-${postfix}'
var runOutputName = '${prefix}-output-${postfix}'

// Image builderを実行するManaged identity用ロール
resource customRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' = {
  name: guid(roleName)
  properties: {
    roleName: roleName
    description: 'ImageBuilder実行者用カスタムロール'
    assignableScopes: [
      resourceGroup().id
    ]
    permissions: [
      {
        actions: [
          'Microsoft.Compute/galleries/read'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/write'
          'Microsoft.Compute/images/write'
          'Microsoft.Compute/images/read'
          'Microsoft.Compute/images/delete'
        ]
        notActions: []
        dataActions: []
        notDataActions: []
      }
    ]
  }
}

// Image builderを実行するManaged identity
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: identityName
  location: location
}

// ロール割り当て
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(identity.name, customRole.id)
  properties: {
    principalId: identity.properties.principalId
    roleDefinitionId: customRole.id
  }
}

// 共有ギャラリー
resource gallery 'Microsoft.Compute/galleries@2023-07-03' = {
  name: galleryName
  location: location
}

// 共有ギャラリー イメージ
resource galleryImage 'Microsoft.Compute/galleries/images@2023-07-03' = {
  parent: gallery
  name: imageName
  location: location
  properties: {
    identifier: {
      offer: 'Windows'
      publisher: imagePublisher
      sku: imageSku
    }
    osState: 'Generalized'
    osType: 'Windows'
    hyperVGeneration: 'V2'
    architecture: 'x64'
  }
}

// 日本語化 Windows テンプレート
resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2023-07-01' = {
  name: imageTemplateName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: '${galleryImage.id}/versions/1.0.0'
        runOutputName: runOutputName
        replicationRegions: ['japaneast']
        storageAccountType: 'Standard_LRS'
        excludeFromLatest: true
      }
    ]
    source: {
      type: 'PlatformImage'
      publisher: sourceImagePublisher
      offer: sourceImageOffer
      sku: sourceImageSku
      version: sourceImageVersion
    }
    vmProfile: {
      vmSize: 'Standard_D4ds_v5'
      osDiskSizeGB: 127
    }
    customize: [
      {
        name: 'InstallFSLogix'
        type: 'PowerShell'
        runElevated: true
        runAsSystem: true
        inline: [
          '$ProgressPreference = "SilentlyContinue"'
          'New-Item -Path C:\\pkg -ItemType Directory'
          'Write-Host "Try to download Fslogix package."'
          'Invoke-WebRequest -Uri https://aka.ms/fslogix_download -OutFile c:\\pkg\\setup.zip'
          'Expand-Archive -LiteralPath C:\\pkg\\setup.zip -DestinationPath c:\\pkg -Force'
          'Start-Process -FilePath "c:\\pkg\\x64\\Release\\FSLogixAppsSetup.exe" -ArgumentList "/install /quiet" -Wait -Passthru -Verbose'
        ]
      }
      {
        name: 'Japanize'
        type: 'PowerShell'
        runElevated: true
        runAsSystem: true
        inline: [
          // 日本語パックをインストール
          'Install-Language ja-JP -CopyToSettings'
          // 優先言語を日本語にする
          'Set-SystemPreferredUILanguage ja-JP'
          // 表示言語を日本語にする
          'Set-WinUILanguageOverride -Language ja-JP'
          // 言語リストの先頭を日本語にする
          'Set-WinUserLanguageList -LanguageList ja-JP,en-US -Force'
          // ロケーションを日本にする
          'Set-WinHomeLocation -GeoId 0x7a'
          // タイムゾーンを日本にする
          'Set-TimeZone -id "Tokyo Standard Time"'
          // システムロケールを日本語にする
          'Set-WinSystemLocale -SystemLocale ja-JP'
          // 設定をログイン画面と新規ユーザにコピーする
          'Copy-UserInternationalSettingsToSystem -welcomescreen $true -newuser $true'
        ]
      }
      {
        type: 'WindowsRestart'
        restartCheckCommand: 'Write-Host "restarting post Japanize."'
        restartTimeout: '5m'
      }
    ]
  }
}
