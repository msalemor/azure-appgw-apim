# Azure Application Gateway and API Management

## Reference Document
https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-integrate-internal-vnet-appgateway

## Main scenario

To inspect incoming traffic into API Manage portal and gateway using Application Gateway's WAF capabilities. Under this scenario API management in deployed in internal mode. As such API Management is able to connect to internal services that receive an internal IP and never get exposed to the public internet. Development of these services can leverage App Service Environment, VMs, and Kubernetes.

## Files

### Powershell - DeployServices.ps1

### CreateCertificates.ps1
