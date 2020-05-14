# Certificate configuration
$domain = "yourdomain.com"
$gatewayDomain = "api.$domain"
$portalDomain = "portal.$domain"
$certPath = "c:\certs"
$certPwd="YourVerySecureP@ssword"

# Create the ROOT certiface
$params = @{
  DnsName = $domain
  KeyLength = 2048
  KeyAlgorithm = 'RSA'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotAfter = (Get-Date).AddYears(5)
  CertStoreLocation = 'Cert:\LocalMachine\My'
  KeyUsage = 'CertSign','CRLSign' #fixes invalid cert error
}
$rootCA = New-SelfSignedCertificate @params
# Export the ROOT certificate
Export-Certificate -Cert $rootCA -FilePath "$certPath\rootCA.cer"
# Import the ROOT certificate into the trusted store
Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\Root' -FilePath "$certPath\rootCA.cer"

# Create the gateway certificate signed by the root CA
$params = @{
  DnsName = $gatewayDomain
  Signer = $rootCA
  KeyLength = 2048
  KeyAlgorithm = 'RSA'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotAfter = (Get-date).AddYears(2)
  CertStoreLocation = 'Cert:\LocalMachine\My'
}
$gatewayCert = New-SelfSignedCertificate @params
# Export the gateway CER certificate
Export-Certificate -Cert $gatewayCert -FilePath "$certPath\$gatewayDomain.cer"
# Export the gateway PFX certificate
Export-PfxCertificate -Cert $gatewayCert -FilePath "$certPath\$gatewayDomain.pfx" -Password (ConvertTo-SecureString -AsPlainText $certPwd -Force)

# Create the portal certificate signed by the root CA
$params = @{
  DnsName = $portalDomain
  Signer = $rootCA
  KeyLength = 2048
  KeyAlgorithm = 'RSA'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotAfter = (Get-date).AddYears(2)
  CertStoreLocation = 'Cert:\LocalMachine\My'
}
$portalCert = New-SelfSignedCertificate @params
# Export the portal CER certificate
Export-Certificate -Cert $portalCert -FilePath "$certPath\$portalDomain.cer"
# Export the portal PFX certificate
Export-PfxCertificate -Cert $portalCert -FilePath "$certPath\$portalDomain.pfx" -Password (ConvertTo-SecureString -AsPlainText $certPwd -Force)

