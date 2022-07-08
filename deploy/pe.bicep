@description('Location for all resources.')
param location string = resourceGroup().location


var privateEndpointName = 'myPrivateEndpoint'


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: server.id
          groupIds: [
            'server'
          ]
        }
      }
    ]
  }
  dependsOn: [
    vnet
  ]
}

