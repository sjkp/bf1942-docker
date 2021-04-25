param containerGroupName string
param location string
param containerName string
param imageName string
param dnsLabelName string

param serverPassword string {
  secure: true
}

param adminPassword string {
  secure: true
}

param serverName string

param memoryGB int = 4
param cpu int = 1

var storageName = take('storage${uniqueString(resourceGroup().id)}',20)
var fileShareName = 'bf1942'

resource storage 'Microsoft.Storage/storageAccounts@2020-08-01-preview' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name:  'Standard_LRS'
  }  
  properties: {

  }
}

resource fileshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2020-08-01-preview' = {
  dependsOn: [
    storage
  ]
  name: '${storageName}/default/${fileShareName}'
}

var storageKey = listKeys(storage.id, '2019-06-01').keys[0].value

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2019-12-01' = {
  name: containerGroupName
  location: location
  tags: {}  
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: imageName
          command: [          
          ]
          ports: [
            {
              port: 14567
              protocol: 'UDP'
            }
            {
              port: 15667
              protocol: 'TCP'
            }
            {
              port: 22000
              protocol: 'UDP'
            }
            {
              port: 23000
              protocol: 'UDP'
            }
          ]
          environmentVariables: [
            {
              name: 'BFSM'
              value: 'yes'
            }
            {
              name: 'SERVER_NAME'
              value: serverName
            }
            {
              name: 'SERVER_PASSWORD'
              value: serverPassword
            }
            {
              name: 'SERVER_MESSAGE'
              value: ''
            }
            {
              name: 'ADMIN_PASSWORD'
              value: adminPassword
            }
          ]
          resources: {
            requests: {
              memoryInGB: memoryGB
              cpu: cpu
              
            }            
          }
          // volumeMounts: [
          //   {
          //     name: 'bf1942'
          //     mountPath: '/data/mods/bf1942/settings'
          //     readOnly: false
          //   }
          // ]
        }
      }
    ]
    restartPolicy: 'Always'
    ipAddress: {
      ports: [
        {
          port: 14567
          protocol: 'UDP'
        }
        {
          port: 15667
          protocol: 'TCP'
        }
        {
          port: 22000
          protocol: 'UDP'
        }
        {
          port: 23000
          protocol: 'UDP'
        }
      ]
      type: 'Public'      
      dnsNameLabel: dnsLabelName
    }
    osType: 'Linux'
    // volumes: [
    //   {
    //     name: 'bf1942'
    //     azureFile: {
    //       shareName: fileShareName
    //       readOnly: false          
    //       storageAccountName: storageName
    //       storageAccountKey: storageKey
    //     }       
    //   }
    // ]   
    sku: 'Standard'   
  }
}

output ipAddress string = containerGroup.properties.ipAddress.ip