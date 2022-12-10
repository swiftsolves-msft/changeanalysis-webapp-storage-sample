# The Cloud Album Web App with Storage

A basic album web app for displaying and uploading pictures. Uses Azure App Services web app and Storage account. The Storage account is secured through a VNET.

## Getting Started

### Prerequisites
- .NET 7.0 or above. [Download](https://dotnet.microsoft.com/download)
- Azure CLI. [Install](https://docs.microsoft.com/cli/azure/install-azure-cli)


### Quickstart

1. clone this repository and change the working directory to this project folder.
    ```
    git clone https://github.com/Azure-Samples/changeanalysis-webapp-storage-sample.git
    cd changeanalysis-webapp-storage-sample
    ```

2. Open **Publish-WebApp.ps1**. Edit the *SUBSCRIPTION_ID* and *LOCATION* environment variables.

3. Run the script from the current project folder *changeanalysis-webapp-storage-sample*
    ```
    ./Publish-WebApp.ps1
    ```


## Demo

Launch your web app. You can see a carousel of images displaying slide shows similar to the following:

![Web App home page](./media/screenshot1.jpg)

Click on **Upload Picture** on to the navigation bar. Upload your own picture and see it displaying in the album.

![Upload your picture](./media/screenshot2.jpg)

## Clean up

Delete the resource group

    
    az group delete -n {resourcegroup_name}
    

