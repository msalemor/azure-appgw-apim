$domain = "yourdomain.com"
$gatewayDomain = "api.$domain"
$portalDomain = "portal.$domain"
$path = "c:\certs"
$certPwd="P@tojit0"

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
Export-Certificate -Cert $rootCA -FilePath "$path\rootCA.cer"
Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\Root' -FilePath "$path\rootCA.cer"

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
Export-Certificate -Cert $gatewayCert -FilePath "$path\$gatewayDomain.cer"
Export-PfxCertificate -Cert $gatewayCert -FilePath "$path\$gatewayDomain.pfx" -Password (ConvertTo-SecureString -AsPlainText $certPwd -Force)

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
Export-Certificate -Cert $portalCert -FilePath "$path\$portalDomain.cer"
Export-PfxCertificate -Cert $portalCert -FilePath "$path\$portalDomain.pfx" -Password (ConvertTo-SecureString -AsPlainText $certPwd -Force)

