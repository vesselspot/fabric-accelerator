// Parameters
@description('Location where resources will be deployed. Defaults to resource group location')
param location string = resourceGroup().location

@description('Cost Centre tag that will be applied to all resources in this deployment')
param cost_centre_tag string

@description('System Owner tag that will be applied to all resources in this deployment')
param owner_tag string

@description('Subject Matter Expert (SME) tag that will be applied to all resources in this deployment')
param sme_tag string

@description('Audit Storage name')
param audit_storage_name string

@description('Datalake SKU. Allowed values are Premium_LRS, Premium_ZRS, Standard_GRS, Standard_GZRS, Standard_LRS,Standard_RAGRS, Standard_RAGZRS, Standard_ZRS')
@allowed([
'Premium_LRS'
'Premium_ZRS'
'Standard_GRS'
'Standard_GZRS'
'Standard_LRS'
'Standard_RAGRS'
'Standard_RAGZRS'
'Standard_ZRS'
])
param audit_storage_sku string ='Standard_LRS'

@description('Audit Log Analytic Workspace name')
param audit_loganalytics_name string

// @description('Fabric Resource Group')
// param fabricrg string

// @description('Name of SQL Server to be audited')
// param sqlserver_name string

// Variables
var suffix = uniqueString(resourceGroup().id)
var audit_storage_uniquename = substring('${audit_storage_name}${suffix}',0,24)
var audit_loganalytics_uniquename = '${audit_loganalytics_name}-${suffix}'

// Create a Storage Account for Audit Logs
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: audit_storage_uniquename
  location: location
  tags: {
    CostCentre: cost_centre_tag
    Owner: owner_tag
    SME: sme_tag
    }
  sku: {name: audit_storage_sku}
  kind:  'StorageV2'
  identity: {type: 'SystemAssigned'}
  properties: {
    accessTier: 'Cool'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: false
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

// Create a Log Analytics Workspace
resource loganalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: audit_loganalytics_uniquename
  location: location
  tags: {
    CostCentre: cost_centre_tag
    Owner: owner_tag
    SME: sme_tag
    }
  identity: {type: 'SystemAssigned'}
  properties: {
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 30
    sku: {name: 'PerGB2018'}
  }
}

// resource sqlserver 'Microsoft.Sql/servers@2023-08-01-preview' existing = {
//   name: sqlserver_name
//   scope: resourceGroup(fabricrg)
// }


// //Role Assignment
// @description('This is the built-in Storage Blob Contributor role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
// resource sbdContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
//   scope: subscription()
//   name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
// }

// //Grant Storage Blob Data Contributor role to SQL Server  
// resource grant_sbdc_role 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   name: guid(subscription().subscriptionId, sqlserver.name, sbdContributorRoleDefinition.id)
//   scope: storageAccount
//   properties: {
//     principalType: 'ServicePrincipal'
//     principalId: storageAccount.identity.principalId
//     roleDefinitionId: sbdContributorRoleDefinition.id
//   }
// }


output audit_storage_uniquename string = audit_storage_uniquename
