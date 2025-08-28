@description('App Service Plan name')
param name string

@description('Location for the resource')
param location string

@description('App Service Plan SKU')
param sku string = 'B1'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: sku
    tier: sku == 'B1' ? 'Basic' : (sku == 'S1' ? 'Standard' : 'Premium')
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name
