@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the App Service app to deploy. This name must be globally unique.')
param appServiceAppName string

@description('The name of the storage account to deploy. This name must be globbaly unique.')
param StorageAccountName string

@description('The name of the queue to deploy for processing orders')
param processOrdaerQueueName string

@description('The type of the environment. This must be nonprod or prod.')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

var appServicePlanName = 'toy-product-launch-plan'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2_v3' : 'F1'

resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'storageAccountName'
          value: StorageAccountName
        }
        {
          name: 'ProcessOrderQueueName'
          value: processOrdaerQueueName
        }
      ]
    }
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
