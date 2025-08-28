@description('Search Service name')
param name string

@description('Location for the resource')
param location string

@description('Search Service SKU')
param sku string = 'basic'

@description('App Service managed identity principal ID')
param appServicePrincipalId string

resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    networkRuleSet: {
      ipRules: []
    }
    encryptionWithCmk: {
      enforcement: 'Unspecified'
    }
    disableLocalAuth: false
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
    semanticSearch: 'free'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Grant App Service Search Index Data Reader role
resource searchIndexDataReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '1407120a-92aa-4202-b7e9-c0e197c71c8f' // Search Index Data Reader
}

resource appServiceSearchReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: searchService
  name: guid(searchService.id, appServicePrincipalId, searchIndexDataReaderRoleDefinition.id)
  properties: {
    roleDefinitionId: searchIndexDataReaderRoleDefinition.id
    principalId: appServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant App Service Search Index Data Contributor role
resource searchIndexDataContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '8ebe5a00-799e-43f5-93ac-243d3dce84a7' // Search Index Data Contributor
}

resource appServiceSearchContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: searchService
  name: guid(searchService.id, appServicePrincipalId, searchIndexDataContributorRoleDefinition.id)
  properties: {
    roleDefinitionId: searchIndexDataContributorRoleDefinition.id
    principalId: appServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

output id string = searchService.id
output name string = searchService.name
output endpoint string = 'https://${searchService.name}.search.windows.net'
@secure()
output adminKey string = searchService.listAdminKeys().primaryKey
