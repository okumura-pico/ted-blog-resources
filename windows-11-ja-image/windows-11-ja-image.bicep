param prefix string = 'avd'
param postfix string = uniqueString(resourceGroup().id)
param imagePublisher string = 'OurCompany'
param imageSku string = 'win11-23h2-avd-ja'
param sourceImagePublisher string = 'MicrosoftWindowsDesktop'
param sourceImageOffer string = 'windows-11'
param sourceImageSku string = 'win11-23h2-avd'
// param sourceImageVersion string = '22631.3593.240511'
param sourceImageVersion string = 'latest'

var roleName = '${prefix}-builder-role-${postfix}'
var identityName = '${prefix}-builder-identity-${postfix}'
var galleryName = '${prefix}_gallery_${postfix}'
var imageName = 'Windows-11-ja'
var imageTemplateName = '${prefix}-image-template-${postfix}'
var location = resourceGroup().location
var roleId = guid(roleName)
var runOutputName = '${prefix}-output-${postfix}'

// Image builderを実行するManaged identity用ロール
resource customRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' = {
  name: roleId
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
  name: guid(identityName, roleName)
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
      vmSize: 'Standard_B2ms'
      osDiskSizeGB: 127
    }
    customize: [
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
        restartCheckCommand: 'write-host "restarting post Teams Install"'
        restartTimeout: '5m'
      }
      {
        type: 'WindowsUpdate'
        searchCriteria: 'IsInstalled=0'
        filters: [
          'exclude:$_.Title -like \'*Preview*\''
          'include:$true'
        ]
        updateLimit: 40
      }
    ]
  }
}
