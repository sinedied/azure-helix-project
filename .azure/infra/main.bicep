
// ***************************************************************************
// THIS FILE IS AUTO-GENERATED, DO NOT EDIT IT MANUALLY!
// If you need to make changes, edit the file `blue.yaml`.
// ***************************************************************************

// ---------------------------------------------------------------------------
// Global parameters 
// ---------------------------------------------------------------------------

@minLength(1)
@maxLength(24)
@description('The name of your project')
param projectName string

@minLength(1)
@maxLength(10)
@description('The name of the environment')
param environment string = 'prod'

@description('The Azure region where all resources will be created')
param location string = 'eastus'

// ---------------------------------------------------------------------------

var commonTags = {
  project: projectName
  environment: environment
  managedBy: 'blue'
}

targetScope = 'resourceGroup'

module storage './modules/storage.bicep' = {
  name: 'storage'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
  }
}

module insights './modules/insights.bicep' = {
  name: 'insights'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
  }
}

var functionNames = [
  'helix-function'
]

module functions './modules/function.bicep' = [for functionName in functionNames: {
  name: 'func-${functionName}'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
    functionName: functionName
  }
  dependsOn: [storage, insights]
}]

output resourceGroupName string = resourceGroup().name

output appInsightsName string = insights.outputs.appInsightsName
output storageAccountName string = storage.outputs.storageAccountName

output functionNames array = functionNames
output functionAppNames array = [for (name, i) in functionNames: functions[i].outputs.functionAppName]
output functionAppUrls array = [for (name, i) in functionNames: functions[i].outputs.functionAppUrl]
