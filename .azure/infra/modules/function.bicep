// ---------------------------------------------------------------------------
// Common parameters for all modules
// ---------------------------------------------------------------------------

@minLength(1)
@maxLength(24)
@description('The name of your project')
param projectName string

@minLength(1)
@maxLength(10)
@description('The name of the environment')
param environment string

@description('The Azure region where all resources will be created')
param location string = resourceGroup().location

@description('Tags for the resources')
param tags object = {}

// ---------------------------------------------------------------------------
// Resource-specific parameters
// ---------------------------------------------------------------------------

@description('Specify the service tier')
@allowed([
  'EP1'
  'EP2'
  'EP3'
])
param tier string = 'EP1'

@description('The name of the function to deploy')
param functionName string

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: 'st${uid}'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: 'insights-${projectName}-${environment}-${uid}'
}

var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
var functionUid = uniqueString(uid, functionName)

// Azure App Service Plan
// https://learn.microsoft.com/azure/templates/microsoft.web/serverfarms?pivots=deployment-language-bicep
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'asp-${functionUid}'
  location: location
  kind: 'functionapp'
  tags: tags
  properties: {
    maximumElasticWorkerCount: 4
    reserved: true
  }
  sku: {
    name: tier
    tier: 'ElasticPremium'
    size: tier
    family: 'EP'
  }
}

// Azure Function App
// https://learn.microsoft.com/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'func-${functionUid}'
  location: location
  kind: 'functionapp,linux'
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: false
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageAccountConnectionString
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(appInsights.id, appInsights.apiVersion).InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: reference(appInsights.id, appInsights.apiVersion).ConnectionString
        }
        {
          name: 'HELIX_HOSTNAME'
          value: 'main--azure-helix-project--sinedied.hlx.live'
        }
      ]
      use32BitWorkerProcess: false
      netFrameworkVersion: 'v4.6'
      linuxFxVersion: 'Node|16'
    }
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output appServicePlanName string = appServicePlan.name
output functionAppName string = functionApp.name
output functionAppUrl string = functionApp.properties.defaultHostName
