Param(
    [switch]$noAzureLogin
)

#Generate suffix to ensure the resource names are unique
$chars = "abcdefghijkmnopqrstuvwxyz0123456789".ToCharArray()
$suffix = ""
1..6 | ForEach-Object {$suffix += $chars | Get-Random}

#Environment variables
$SUBSCRIPTION_ID=""
$RESOURCE_GROUP="cloudalbumrg-$suffix"
$LOCATION=""
$VNET_NAME="cloudalbumvnet-$suffix"
$STORAGE_NAME="cloudalbumstrg$suffix"
$APPSERVICE_PLAN_NAME="cloudalbumplan-$suffix"
$WEBAPP_NAME="cloudalbumwebapp-$suffix"

#Connnect to an Azure subscription
if(!$noAzureLogin)
{
    az login
}

az account set --s $SUBSCRIPTION_ID

#Create resource group if doesn't exist
$rgCheck = az group exists --name $RESOURCE_GROUP
if ($rgCheck -eq "false")
{
    Write-Output "Creating resource group $RESOURCE_GROUP ..."
    az group create --name $RESOURCE_GROUP --location $LOCATION
}
else
{
    Write-Output "$RESOURCE_GROUP exists, skip creation"
}

#Create VNET
$vnetCheck = az network vnet list --resource-group $RESOURCE_GROUP --query "[?name=='$VNET_NAME']" | ConvertFrom-Json
$vnetExists = $vnetCheck.Length -gt 0
if(!$vnetExists)
{
    az network vnet create -g $RESOURCE_GROUP -n $VNET_NAME
    az network vnet subnet create --address-prefixes 10.0.0.0/16 --name "default" --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME  --service-endpoints "Microsoft.Storage"
}


#Create Storage Account
$strgCheck = az storage account list --resource-group $RESOURCE_GROUP --query "[?name=='$STORAGE_NAME']" | ConvertFrom-Json
$strgExists = $strgCheck.Length -gt 0
if(!$strgExists)
{
    az storage account create -g $RESOURCE_GROUP -n $STORAGE_NAME --default-action Deny  --vnet-name $VNET_NAME --subnet "default"  --routing-choice MicrosoftRouting
}


#Create App Service Plan
$planCheck = az appservice plan list --resource-group $RESOURCE_GROUP --query "[?name=='$APPSERVICE_PLAN_NAME']" | ConvertFrom-Json
$planExists = $planCheck.Length -gt 0
if(!$planExists)
{
    az appservice plan create --resource-group $RESOURCE_GROUP --name $APPSERVICE_PLAN_NAME --sku B1
}

#Create Web app
#Configure Web App to use VNET for outbound
#Set Web App configuration setting to use Storage Connection String
$webappCheck = az webapp list --resource $RESOURCE_GROUP --query "[?name=='$WEBAPP_NAME']" | ConvertFrom-Json
$webappExists = $webappCheck.Length -gt 0
if(!$webappExists)
{
    az webapp create -g $RESOURCE_GROUP -n $WEBAPP_NAME -p $APPSERVICE_PLAN_NAME --vnet $VNET_NAME --subnet "default"
}

$storageJson=az storage account show-connection-string --name $STORAGE_NAME --resource-group $RESOURCE_GROUP | ConvertFrom-Json
$storageConnection=$storageJson.connectionString
az webapp config appsettings set -g $RESOURCE_GROUP -n $WEBAPP_NAME --settings AzureStorageConnection=$storageConnection


#Build Web App
dotnet publish
Compress-Archive -Path .\bin\Debug\net7.0\publish\* -DestinationPath .\deploy.zip
#Deploy Web App
az webapp deployment source config-zip --src .\deploy.zip --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP


