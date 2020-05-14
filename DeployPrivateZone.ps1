## Settings
$domain = "yourdomain.com"
$vnetID = "<--The VNET ID from the subscription-->"
$name = "myNetworkLink"

## Load the private zone module
Install-Module -Name Az.PrivateDns -force

## Create a Zone
$zone = New-AzPrivateDnsZone -Name private.$domain -ResourceGroupName $resGroupName

## Connects the network to the private zone
$link = New-AzPrivateDnsVirtualNetworkLink -ZoneName private.$domain `
  -ResourceGroupName $resGroupName -Name $name `
  -VirtualNetworkId $vnetID -EnableRegistration
