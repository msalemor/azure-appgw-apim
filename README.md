# Azure Application Gateway and API Management

## Reference Document
https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-integrate-internal-vnet-appgateway

## Main scenario

To inspect incoming traffic into API Manage portal and gateway using Application Gateway's WAF capabilities. Under this scenario API management in deployed in internal mode. As such API Management is able to connect to internal services that receive an internal IP and never get exposed to the public internet. Development of these services can leverage App Service Environment, VMs, and Kubernetes.

## Scripts included in this repo

### Create the self-signed certifcates (Optional)
> Note: PowerShell - CreateSelfSignedCertificates.ps1

- Certifices are used to set the portal and gateway hostnames in API management
- They are also used to configure communication between Application Gateway and API Management
- API Management support self-signed certificates

#### What will the script do?

- The script will create a self-signed root CA
- It will also create the api and gateway certificate signed by the root CA

### Deploy API Management and Application Gateway

> Note: Powershell - DeployServices.ps1

Remeber to change the parameters before executing this script

```powershell
```

#### Steps
#### Create the Vnet and subnet
#### Create the API Management in the APIM subnet
#### Create a public IP
#### Create the Application Gateway

### (Optional) Deploy an Azure Private DNS Zone

> Note: Powershell - DeployPrivaZone.ps1

- It is best practice to references private service by a DNS name in API Management. 
- You may also deploy your own DNS service.


