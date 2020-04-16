## Deploy a private DNS Zone
Install-Module -Name Az.PrivateDns -force

$zone = New-AzPrivateDnsZone -Name private.$domain -ResourceGroupName $resGroupName
$link = New-AzPrivateDnsVirtualNetworkLink -ZoneName private.$domain `
  -ResourceGroupName $resGroupName -Name "mylink" `
  -VirtualNetworkId $vnet.id -EnableRegistration
