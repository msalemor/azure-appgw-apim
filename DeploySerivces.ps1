Connect-AzAccount

# Create resource group
$resGroupName = "apim-appGw-RG" # resource group name
$location = "East US"           # Azure region
New-AzResourceGroup -Name $resGroupName -Location $location

# Create VNet
$appgatewaysubnet = New-AzVirtualNetworkSubnetConfig -Name "apim01" -AddressPrefix "10.0.0.0/24"
$apimsubnet = New-AzVirtualNetworkSubnetConfig -Name "apim02" -AddressPrefix "10.0.1.0/24"
$vnet = New-AzVirtualNetwork -Name "appgwvnet" -ResourceGroupName $resGroupName -Location $location -AddressPrefix "10.0.0.0/16" -Subnet $appgatewaysubnet,$apimsubnet

# Get subnets from the Vnet
$appgatewaysubnetdata = $vnet.Subnets[0]
$apimsubnetdata = $vnet.Subnets[1]

# Set the API Management subnet and other creation settings
$apimVirtualNetwork = New-AzApiManagementVirtualNetwork -SubnetResourceId $apimsubnetdata.Id
$apimServiceName = "YourApiName"       # API Management service instance name
$apimOrganization = "Your Company Name"         # organization name
$apimAdminEmail = "admin@yourdoamin.com" # administrator's email address

# Create API Management in internal mode
$apimService = New-AzApiManagement -ResourceGroupName $resGroupName -Location $location -Name $apimServiceName -Organization $apimOrganization -AdminEmail $apimAdminEmail -VirtualNetwork $apimVirtualNetwork -VpnType "Internal" -Sku "Developer"

# Set the new domains
$domain = "yourdomain.com"
$gatewayHostname = "api.$domain"                 # API gateway host
$portalHostname = "portal.$domain"               # API developer portal host
$gatewayCertCerPath = "D:\certs\ecademo1.com\api.ecademo1.com.cer" # full path to api.contoso.net .cer file
$gatewayCertPfxPath = "D:\certs\ecademo1.com\api.ecademo1.com.pfx" # full path to api.contoso.net .pfx file
$portalCertPfxPath = "D:\certs\ecademo1.com\portal.ecademo1.com.pfx"   # full path to portal.contoso.net .pfx file
$gatewayCertPfxPassword = "P@tojit0"   # password for api.contoso.net pfx certificate
$portalCertPfxPassword = "P@tojit0"    # password for portal.contoso.net pfx certificate

$certPwd = ConvertTo-SecureString -String $gatewayCertPfxPassword -AsPlainText -Force
$certPortalPwd = ConvertTo-SecureString -String $portalCertPfxPassword -AsPlainText -Force

# Set the new hostnames
$proxyHostnameConfig = New-AzApiManagementCustomHostnameConfiguration -Hostname $gatewayHostname -HostnameType Proxy -PfxPath $gatewayCertPfxPath -PfxPassword $certPwd
$portalHostnameConfig = New-AzApiManagementCustomHostnameConfiguration -Hostname $portalHostname -HostnameType DeveloperPortal -PfxPath $portalCertPfxPath -PfxPassword $certPortalPwd
$apimService.ProxyCustomHostnameConfiguration = $proxyHostnameConfig
$apimService.PortalCustomHostnameConfiguration = $portalHostnameConfig

Set-AzApiManagement -InputObject $apimService

## Create a public IP for the Application Gateway
$publicip = New-AzPublicIpAddress -ResourceGroupName $resGroupName -name "publicIP01" -location $location -AllocationMethod Dynamic

## Aplication Gateway

# Add application gateway to the AppGw subnet
$gipconfig = New-AzApplicationGatewayIPConfiguration -Name "gatewayIP01" -Subnet $appgatewaysubnetdata

# Open port 443
$fp01 = New-AzApplicationGatewayFrontendPort -Name "port01"  -Port 443
# Add the public IP to AppGw
$fipconfig01 = New-AzApplicationGatewayFrontendIPConfig -Name "frontend1" -PublicIPAddress $publicip
# Add the APIM Gateway Certificate to AppGw
$cert = New-AzApplicationGatewaySslCertificate -Name "cert01" -CertificateFile $gatewayCertPfxPath -Password $certPwd
# Add the APIM Portal certificate to AppGw
$certPortal = New-AzApplicationGatewaySslCertificate -Name "cert02" -CertificateFile $portalCertPfxPath -Password $certPortalPwd
# Add the APIM Gateway listener to AppGw
$listener = New-AzApplicationGatewayHttpListener -Name "listener01" -Protocol "Https" -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -SslCertificate $cert -HostName $gatewayHostname -RequireServerNameIndication true
# Add the APIM Portal listener to AppGw
$portalListener = New-AzApplicationGatewayHttpListener -Name "listener02" -Protocol "Https" -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -SslCertificate $certPortal -HostName $portalHostname -RequireServerNameIndication true
# Add the APIM Gateway probe to AppGw
# Note: The APIM probe is a well know location at: /status-0123456789abcdef
$apimprobe = New-AzApplicationGatewayProbeConfig -Name "apimproxyprobe" -Protocol "Https" -HostName $gatewayHostname -Path "/status-0123456789abcdef" -Interval 30 -Timeout 120 -UnhealthyThreshold 8
# Add the APIM portal probe to AppGw
$apimPortalProbe = New-AzApplicationGatewayProbeConfig -Name "apimportalprobe" -Protocol "Https" -HostName $portalHostname -Path "/signin" -Interval 60 -Timeout 300 -UnhealthyThreshold 8
# Add the authentication certificate to AppGw
$authcert = New-AzApplicationGatewayAuthenticationCertificate -Name "whitelistcert1" -CertificateFile $gatewayCertCerPath
# Add the API Gateway backend settings to AppGw
$apimPoolSetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolSetting" -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimprobe -AuthenticationCertificates $authcert -RequestTimeout 180
# Add the API Portal backend settings to AppGw
$apimPoolPortalSetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolPortalSetting" -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimPortalProbe -AuthenticationCertificates $authcert -RequestTimeout 180
# Add a backend pool to AppGw
$apimProxyBackendPool = New-AzApplicationGatewayBackendAddressPool -Name "apimbackend" -BackendIPAddresses $apimService.PrivateIPAddresses[0]
# Add a rule to APIM Gateway in backend pool in AppGw
$rule01 = New-AzApplicationGatewayRequestRoutingRule -Name "rule1" -RuleType Basic -HttpListener $listener -BackendAddressPool $apimProxyBackendPool -BackendHttpSettings $apimPoolSetting
# Add a rule to APIM Portal in backend pool in AppGw
$rule02 = New-AzApplicationGatewayRequestRoutingRule -Name "rule2" -RuleType Basic -HttpListener $portalListener -BackendAddressPool $apimProxyBackendPool -BackendHttpSettings $apimPoolPortalSetting
# Set the AppGw SKW to WAF
$sku = New-AzApplicationGatewaySku -Name "WAF_Medium" -Tier "WAF" -Capacity 2
# Enable firewall prevention
$config = New-AzApplicationGatewayWebApplicationFirewallConfiguration -Enabled $true -FirewallMode "Prevention"
# set the AppGw name
$appgwName = "apim-app-gw"
# Create the AppGw
$appgw = New-AzApplicationGateway -Name $appgwName -ResourceGroupName $resGroupName -Location $location -BackendAddressPools $apimProxyBackendPool -BackendHttpSettingsCollection $apimPoolSetting, $apimPoolPortalSetting  -FrontendIpConfigurations $fipconfig01 -GatewayIpConfigurations $gipconfig -FrontendPorts $fp01 -HttpListeners $listener, $portalListener -RequestRoutingRules $rule01, $rule02 -Sku $sku -WebApplicationFirewallConfig $config -SslCertificates $cert, $certPortal -AuthenticationCertificates $authcert -Probes $apimprobe, $apimPortalProbe
