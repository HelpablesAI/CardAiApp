@description('App Service name')
param name string

@description('Location for the resource')
param location string

@description('App Service Plan resource ID')
param appServicePlanId string

@description('Key Vault name')
param keyVaultName string

@description('Storage Account name')
param storageAccountName string

@description('Search Service name')
param searchServiceName string

@description('OpenAI Service endpoint')
param openaiServiceEndpoint string

@description('OpenAI deployment name')
param openaiDeploymentName string

@description('Blob container name')
param blobContainerName string

@description('Application Insights connection string')
param appInsightsConnectionString string

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: 'NODE|20-lts'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      appSettings: [
        {
          name: 'NODE_ENV'
          value: 'production'
        }
        {
          name: 'PORT'
          value: '8000'
        }
        {
          name: 'AZURE_CLIENT_ID'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=azure-client-id)'
        }
        {
          name: 'AZURE_TENANT_ID'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=azure-tenant-id)'
        }
        {
          name: 'AZURE_OPENAI_ENDPOINT'
          value: openaiServiceEndpoint
        }
        {
          name: 'AZURE_OPENAI_DEPLOYMENT_NAME'
          value: openaiDeploymentName
        }
        {
          name: 'AZURE_SEARCH_ENDPOINT'
          value: 'https://${searchServiceName}.search.windows.net'
        }
        {
          name: 'AZURE_STORAGE_ACCOUNT_NAME'
          value: storageAccountName
        }
        {
          name: 'AZURE_BLOB_CONTAINER_NAME'
          value: blobContainerName
        }
        {
          name: 'AZURE_KEYVAULT_NAME'
          value: keyVaultName
        }
        {
          name: 'JWT_ISSUER'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=jwt-issuer)'
        }
        {
          name: 'JWT_AUDIENCE'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=jwt-audience)'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
    httpsOnly: true
    clientAffinityEnabled: false
  }
}

output id string = appService.id
output name string = appService.name
output principalId string = appService.identity.principalId
output defaultHostName string = 'https://${appService.properties.defaultHostName}'
