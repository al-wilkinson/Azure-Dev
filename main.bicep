@description('Database administrator login name')
@minLength(1)
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@secure()
param administratorLoginPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Server Name for Azure database for PostgreSQL')
param serverName string

param serverEdition string = 'Burstable'

param skuSizeGB int = 32

param dbInstanceType string = 'Standard_B1ms'

param haMode string = 'Disabled'

param availabilityZone string = '1'

param version string = '13'

param virtualNetworkName string = 'azure_postgresql_vnet'
param subnetName string = 'azure_postgresql_subnet'

var privateDNSZoneName = '${serverName}.private.postgres.database.azure.com'
var privateDNSZoneLinkName = '${serverName}privatelink'


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-08-01' = {  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          delegations: [
            {
              name: 'dbDelegation'
              properties: {
                serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
              }
            }
          ]
        }
      }
    ]
  }
}


resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDNSZoneName
  location: 'global'
}


resource privateDNSZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDNSZone
  name: privateDNSZoneLinkName
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}


resource serverName_resource 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: serverName
  location: location
  dependsOn: [
    privateDNSZoneLink
  ]
  sku: {
    name: dbInstanceType
    tier: serverEdition
  }
  properties: {
    version: version
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    network: {
      delegatedSubnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, subnetName)
      privateDnsZoneArmResourceId: privateDNSZone.id
    }
    highAvailability: {
      mode: haMode
    }
    storage: {
      storageSizeGB: skuSizeGB
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    availabilityZone: availabilityZone
  }
}
