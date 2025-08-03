
// Parameters
@description('Location where resources will be deployed. Defaults to resource group location')
param location string = resourceGroup().location

@description('Cost Centre tag that will be applied to all resources in this deployment')
param cost_centre_tag string

@description('System Owner tag that will be applied to all resources in this deployment')
param owner_tag string

@description('Subject Matter Expert (SME) tag that will be applied to all resources in this deployment')
param sme_tag string

@description('Key Vault name')
param keyvault_name string

// Variables
var suffix = uniqueString(resourceGroup().id)
var keyvault_uniquename = '${keyvault_name}-${suffix}'

// Create Key Vault
resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' ={
  name: keyvault_uniquename
  location: location
  tags: {
    CostCentre: cost_centre_tag
    Owner: owner_tag
    SME: sme_tag
  }
  properties:{
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    // Default Access Policies. Replace the ObjectID's with your user/group id
    accessPolicies:[
      { tenantId: subscription().tenantId
        objectId: 'd2d63247-3be4-4ca0-be66-825fec763cbe' // Replace this with your user/group ObjectID
        permissions: {secrets:['list','get','set']}
      }
      { tenantId: subscription().tenantId
        objectId: 'be5088ca-babe-412d-b873-e533e3afebaa' // Replace this with your user/group ObjectID
        permissions: {secrets:['list','get','set']}
      }
      { tenantId: subscription().tenantId
        objectId: '9270fa1a-dbb5-4981-a206-2e03dc737b06' // Replace this with your user/group ObjectID
        permissions: {secrets:['list','get']}
      }
    ]
  }
}

output keyvault_name string = keyvault.name  
