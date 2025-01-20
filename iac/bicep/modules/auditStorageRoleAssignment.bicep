@description('Resource name of audit storage account.')
param audit_storage_name string

@description('Resource group of audit storage account is deployed')
param auditrg string

@description('Resource that is granted access to the Storage account')
param granted_resource object

@description('Flag to indicate whether to grant Storable Blob Data Reader role to resource')
param grant_reader bool

@description('Flag to indicate whether to grant Storable Blob Data Contributor role to resource')
param grant_contributor bool


//Get Reference to audit storage account
resource audit_storage_account 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: audit_storage_name
  scope: resourceGroup(auditrg)
}

//Role Assignment
@description('This is the built-in Storage Blob Reader role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor')
resource sbdReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

@description('This is the built-in Storage Blob Contributor role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource sbdContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

//Grant Storage Blob Data Reader role to the resource
resource grant_sbdr_role 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (grant_reader){
  name: guid(subscription().subscriptionId, granted_resource.name, sbdReaderRoleDefinition.id)
  // scope: resourceGroup(auditrg)
  properties: {
    principalType: 'ServicePrincipal'
    principalId: granted_resource.identity.principalId
    roleDefinitionId: sbdReaderRoleDefinition.id
  }
}

//Grant Storage Blob Data Contributor role to the resource
resource grant_sbdc_role 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (grant_contributor){
  name: guid(subscription().subscriptionId, granted_resource.name, sbdContributorRoleDefinition.id)
  // scope: resourceGroup(auditrg)
  properties: {
    principalType: 'ServicePrincipal'
    principalId: granted_resource.identity.principalId
    roleDefinitionId: sbdContributorRoleDefinition.id
  }
}
