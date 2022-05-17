param apimName string
param appInsName string
param location string = resourceGroup().location

@description('Pricing tier of this API Management service')
@allowed([
  'Developer'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('The instance size of this API Management service.')
@allowed([
  1
  2
])
param skuCount int = 1


// Create a workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'myworkspace'
  location: location
}

// Create an App Insights resources connected to the workspace
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsName
  location: location
  kind: 'web'
  properties:{
    Application_Type:'web'
    WorkspaceResourceId: workspace.id
  }
}

resource apim 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: apimName
  location: location
  sku:{
    capacity: skuCount
    name: sku
  }
  properties:{
    virtualNetworkType: 'None'
    publisherEmail: 'andres@iturralde.com'
    publisherName: 'ANDRESI'    
  }  
  tags:{
    ApplicationName: 'Nombre de la aplicación, modulo o canal que está afectando'
    Approver: 'Andres Iturralde'
    Creator: 'Andres Iturralde'
    BusinessUnit: 'CE'
    BudgetAmount: '1000'
    Env: 'Dev'
    Owner: 'Andres Iturralde'
    StartDate: '16052022'
    EndDate: 'N/A'
    Excepciones: 'N/A'
  }
}

resource namedValueAppInsightsKey 'Microsoft.ApiManagement/service/namedValues@2020-06-01-preview' = {
  parent: apim
  name: 'instrumentationKey'
  properties: {
    tags: []
    secret: false
    displayName: 'instrumentationKey'
    value: appInsights.properties.InstrumentationKey
  }
}

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2021-04-01-preview' = {
  parent: apim
  name: 'apimlogger'
  properties:{
    resourceId: appInsights.id
    description: 'Application Insights for APIM'
    loggerType: 'applicationInsights'
    credentials:{
      instrumentationKey: '{{instrumentationKey}}'
    }
  }
}
