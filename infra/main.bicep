// Main infrastructure template for CardAI MCP Server
targetScope = 'resourceGroup'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Environment name (dev, staging, prod)')
param environment string = 'dev'

@description('Application name prefix')
param appName string = 'cardai-mcp'

@description('Your IP address for Key Vault access policy (optional)')
param yourIpAddress string = ''

@description('Azure OpenAI model deployment name')
param openaiModelDeploymentName string = 'text-embedding-ada-002'

@description('Azure OpenAI model name')
param openaiModelName string = 'text-embedding-ada-002'

@description('Azure OpenAI model version')
param openaiModelVersion string = '2'

@description('App Service SKU')
param appServiceSku string = 'B1'

@description('Azure AI Search SKU')
param searchSku string = 'basic'

// Generate unique resource names
var uniqueSuffix = take(uniqueString(resourceGroup().id), 6)
var resourceNames = {
  appService: '${appName}-${environment}-${uniqueSuffix}'
  appServicePlan: '${appName}-plan-${environment}-${uniqueSuffix}'
  keyVault: '${appName}-kv-${environment}-${uniqueSuffix}'
  storage: '${replace(appName, '-', '')}st${environment}${uniqueSuffix}'
  search: '${appName}-search-${environment}-${uniqueSuffix}'
  openai: '${appName}-openai-${environment}-${uniqueSuffix}'
  logAnalytics: '${appName}-logs-${environment}-${uniqueSuffix}'
  appInsights: '${appName}-insights-${environment}-${uniqueSuffix}'
}

// App Service Plan
module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    name: resourceNames.appServicePlan
    location: location
    sku: appServiceSku
  }
}

// App Service
module appService 'modules/app-service.bicep' = {
  name: 'appService'
  params: {
    name: resourceNames.appService
    location: location
    appServicePlanId: appServicePlan.outputs.id
    keyVaultName: keyVault.outputs.name
    storageAccountName: storage.outputs.name
    searchServiceName: search.outputs.name
    openaiServiceEndpoint: openai.outputs.endpoint
    openaiDeploymentName: openaiModelDeploymentName
    blobContainerName: 'documents'
    appInsightsConnectionString: appInsights.outputs.connectionString
  }
}

// Key Vault
module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    name: resourceNames.keyVault
    location: location
    appServicePrincipalId: appService.outputs.principalId
    yourIpAddress: yourIpAddress
  }
}

// Storage Account
module storage 'modules/storage-account.bicep' = {
  name: 'storage'
  params: {
    name: resourceNames.storage
    location: location
    appServicePrincipalId: appService.outputs.principalId
    containerName: 'documents'
  }
}

// Azure AI Search
module search 'modules/search-service.bicep' = {
  name: 'search'
  params: {
    name: resourceNames.search
    location: location
    sku: searchSku
    appServicePrincipalId: appService.outputs.principalId
  }
}

// Azure OpenAI
module openai 'modules/openai-service.bicep' = {
  name: 'openai'
  params: {
    name: resourceNames.openai
    location: location
    appServicePrincipalId: appService.outputs.principalId
    deploymentName: openaiModelDeploymentName
    modelName: openaiModelName
    modelVersion: openaiModelVersion
  }
}

// Log Analytics Workspace
module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'logAnalytics'
  params: {
    name: resourceNames.logAnalytics
    location: location
  }
}

// Application Insights
module appInsights 'modules/app-insights.bicep' = {
  name: 'appInsights'
  params: {
    name: resourceNames.appInsights
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

// Store secrets in Key Vault
module keyVaultSecrets 'modules/key-vault-secrets.bicep' = {
  name: 'keyVaultSecrets'
  params: {
    keyVaultName: keyVault.outputs.name
    searchApiKey: search.outputs.adminKey
    openaiApiKey: openai.outputs.apiKey
  }
  dependsOn: [
    keyVault
    search
    openai
  ]
}

// Outputs
output appServiceName string = appService.outputs.name
output appServiceUrl string = appService.outputs.defaultHostName
output keyVaultName string = keyVault.outputs.name
output storageAccountName string = storage.outputs.name
output searchServiceName string = search.outputs.name
output openaiServiceName string = openai.outputs.name
output resourceGroupName string = resourceGroup().name
