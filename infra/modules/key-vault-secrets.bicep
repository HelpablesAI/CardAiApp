@description('Key Vault name')
param keyVaultName string

@description('Azure Search API key')
@secure()
param searchApiKey string

@description('Azure OpenAI API key')
@secure()
param openaiApiKey string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource searchApiKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'az-search-key'
  properties: {
    value: searchApiKey
    contentType: 'text/plain'
  }
}

resource openaiApiKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'az-openai-key'
  properties: {
    value: openaiApiKey
    contentType: 'text/plain'
  }
}

// Placeholder secrets for JWT configuration
resource azureClientIdSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'azure-client-id'
  properties: {
    value: 'placeholder-update-after-deployment'
    contentType: 'text/plain'
  }
}

resource azureTenantIdSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'azure-tenant-id'
  properties: {
    value: 'placeholder-update-after-deployment'
    contentType: 'text/plain'
  }
}

resource jwtIssuerSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'jwt-issuer'
  properties: {
    value: 'placeholder-update-after-deployment'
    contentType: 'text/plain'
  }
}

resource jwtAudienceSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'jwt-audience'
  properties: {
    value: 'placeholder-update-after-deployment'
    contentType: 'text/plain'
  }
}

output searchApiKeySecretName string = searchApiKeySecret.name
output openaiApiKeySecretName string = openaiApiKeySecret.name
