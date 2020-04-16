# Azure Application Gateway and API Management

## Reference Document
https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-integrate-internal-vnet-appgateway

## Main scenario

To inspect incoming traffic into API Manage portal and gateway using Application Gateway's WAF capabilities. Under this scenario API management in deployed in internal mode. As such API Management is able to connect to internal services that receive an internal IP and never get exposed to the public internet. Development of these services can leverage App Service Environment, VMs, and Kubernetes.

## What is included in this repo

### (optional) Create the self-signed certifcates
> Note: PowerShell - CreateSelfSignedCertificates.ps1

- Certifices are used to set the portal and gateway names in API management
- They are also used to create the listeners in Application Gateway

### Deploy API Management and Application Gateway

> Note: Powershell - DeployServices.ps1

Remeber to change the parameters before executing this script

```powershell
```

### (Optional) Deploy an Azure Private DNS Zone

> Note: Powershell - DeployPrivaZone.ps1


