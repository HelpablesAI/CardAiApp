@description('OpenAI Service name')
param name string

@description('Location for the resource')
param location string

@description('App Service managed identity principal ID')
param appServicePrincipalId string

@description('Model deployment name')
param deploymentName string

@description('Model name')
param modelName string

@description('Model version')
param modelVersion string

resource openaiService 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: name
    networkAcls: {
      defaultAction: 'Allow'
    }
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
}

resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: openaiService
  name: deploymentName
  properties: {
    model: {
      format: 'OpenAI'
      name: modelName
      version: modelVersion
    }
    versionUpgradeOption: 'OnceCurrentVersionExpired'
    currentCapacity: 30
    raiPolicyName: 'Microsoft.Default'
  }
}

// Grant App Service Cognitive Services OpenAI User role
resource cognitiveServicesOpenAIUserRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' // Cognitive Services OpenAI User
}

resource appServiceOpenAIRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: openaiService
  name: guid(openaiService.id, appServicePrincipalId, cognitiveServicesOpenAIUserRoleDefinition.id)
  properties: {
    roleDefinitionId: cognitiveServicesOpenAIUserRoleDefinition.id
    principalId: appServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

output id string = openaiService.id
output name string = openaiService.name
output endpoint string = openaiService.properties.endpoint
@secure()
output apiKey string = openaiService.listKeys().key1
