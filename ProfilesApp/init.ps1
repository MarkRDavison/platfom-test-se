param (
    [parameter(Mandatory=$false)] 
    $tearDown = $false,

    [parameter(Mandatory=$false)] 
    $force = $false,

    [parameter(Mandatory=$false)] 
    $tenant = "xxx.onmicrosoft.com",
    
    [parameter(Mandatory=$true)] 
    $subscriptionName = "testsub",

    [parameter(Mandatory=$false)] 
    $name = "test2",

    [parameter(Mandatory=$false)] 
    $owner = "preet",

    [parameter(Mandatory=$true)] 
    [SecureString] $sqlPassword
)

# login and set subscription
az login --tenant $tenant
az account set --subscription $subscriptionName

$location= "AustraliaEast"
$namePrefix = "d-aue-quasar-interviewtest"

$resourceGroupName = "$namePrefix-$name-rg"

$sqlServerName = "$namePrefix-$name-sql"
$sqlUsername = "$name-admin"

$sqlDbName = "$namePrefix-$name-db"

$acrName = "$namePrefix-$name-acr" -replace "-", ""

$appServicePlanName = "$namePrefix-$name-asplan" 
$webAppName = "$appServicePlanName-app" 

Write-Host "acr name: $acrName"

$acrUsername = $null
$acrPw = $null
$acrLoginServer = $null
$acrImageName = $null
$grafanaContainerInstanceName = "$namePrefix-$name-grafana-ci"

function CreateContainerInstance()
{
    Write-Output "Container Instance $grafanaContainerInstanceName"

    $resource = (az container show --name $grafanaContainerInstanceName --resource-group $resourceGroupName )
    if ($force -and $resource) {
        Write-Output "exists. deleting"
        az container delete --name $grafanaContainerInstanceName --resource-group $resourceGroupName
        $resource = $null
    } 

    if (!$resource) {
        # TODO: Variable scopes
        $acrUsername = (az acr credential show -n  $acrName --query "username")
        $acrPw = (az acr credential show -n  $acrName --query "passwords[0].value")
        $acrloginserver=(az acr show --name $acrName --query loginServer)
        $acrImageName="$acrloginserver/grafana:v1"
        Write-Output "doesn't exist. creating"
        Write-Host "az container create --name $grafanaContainerInstanceName --resource-group $resourceGroupName --location $location --dns-name-label $grafanaContainerInstanceName --registry-username $acrUsername --registry-password $acrPw --registry-login-server $acrLoginServer --ports 3000 --image  $acrImageName" -ForegroundColor Cyan
        $resource = ( az container create --name $grafanaContainerInstanceName --resource-group $resourceGroupName --location $location --dns-name-label $grafanaContainerInstanceName --registry-username $acrUsername --registry-password $acrPw --registry-login-server $acrLoginServer --ports 3000 --image  $acrImageName)
    }

    Write-Output $resource
    Write-Output "Grafana is running on"
    az container show --name $grafanaContainerInstanceName --resource-group $resourceGroupName --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}"
}

function CreateWebapp()
{
    Write-Output "Webapp $webAppName"

    $resource = (az webapp show --name $webAppName --resource-group $resourceGroupName )
    if ($force -and $resource) {
        Write-Output "exists. deleting"
        az webapp delete --name $webAppName  --resource-group $resourceGroupName  
        $resource = $null
    } 

    if (!$resource) {
        Write-Output "doesn't exist. creating"
        # need the '"" in that form as powershell interprets the | char
        $resource = (az webapp create --name $webAppName --resource-group $resourceGroupName  --plan $appServicePlanName --deployment-local-git --runtime '"DOTNETCORE|3.1"')
    }

    $dbConnectionString = (az sql db show-connection-string --client ado.net --server $sqlServerName --name "MyDbConnection")
    $dbConnectionString = $dbConnectionString -replace "<username>", $sqlUsername  
    $dbConnectionString = $dbConnectionString -replace "<password>", $sqlPassword  
    az webapp config connection-string set --resource-group $resourceGroupName --name $webAppName --settings MyDbConnection=$dbConnectionString --connection-string-type SQLAzure
    az webapp deployment source config-local-git --resource-group $resourceGroupName --name $webAppName
    $gitUrl = (az webapp deployment source config-local-git --resource-group $resourceGroupName --name $webAppName --query url)

    # this is set at the subscription level
    az webapp deployment user set --user-name "serko-user" --password "serko-password"
    
    Write-Output $resource    
    
    Write-Output "Add the following remote to your applictions and push" 
    Write-Output "\n"
    Write-Output "git remote rm azure"
    Write-Output "git remote add azure $gitUrl"
    Write-Output "git push azure"
}

function CreateAppServicePlan()
{
    Write-Output "App Service Plan $appServicePlanName"

    $resource = (az appservice plan show --name $appServicePlanName --resource-group $resourceGroupName )
    if ($force -and $resource) {
        Write-Output "exists. deleting"
        az appservice plan delete --name $appServicePlanName  --resource-group $resourceGroupName
        $resource = $null
    } 

    if (!$resource) {
        Write-Output "doesn't exist. creating"
        $resource = (az appservice plan create --name $appServicePlanName --resource-group $resourceGroupName --sku "F1" --location $location)
    }

    Write-Output $resource
}

function UploadGrafanaImage()
{
    Write-Output "Upload Grafana Instance to $acrName"

    $dockerHubImageName='grafana/grafana'
    docker image pull $dockerHubImageName

    $acrloginserver=(az acr show --name $acrName --query loginServer)
    write-Output "Login server $acrloginserver"

    $acrUsername = (az acr credential show -n  $acrName --query "username")
    $acrPw = (az acr credential show -n  $acrName --query "passwords[0].value")

    $acrImageName="$acrloginserver/grafana:v1"
    Write-Output "Acr Image Name: $acrImageName"
    
    Write-Output "ACR username: $acrUsername"
    Write-Output "ACR pwd: $acrPw"
    
    Write-Output "Uploading image"
    docker tag $dockerHubImageName $acrImageName
    az acr login --name $acrName --username $acrUsername --password $acrPw
    docker push $acrImageName

    # keep these here for debuging in future
    # az acr repository list --name $acrName
    # az acr repository show-tags --name $acrName --repository "grafana"

    Write-Output "Acr Image Name: $acrImageName"
}


function CreateContainerRegistry()
{
    Write-Output "Container Registry $acrName"

    $resource = (az acr show --name $acrName)
    if ($force -and $resource) {
        Write-Output "exists. deleting"
        az acr delete --name $acrName  --resource-group $resourceGroupName
        $resource = $null
    } 

    if (!$resource) {
        Write-Output "doesn't exist. creating"
        $resource = (az acr create --name $acrName  --resource-group $resourceGroupName --sku Basic --admin-enabled)
    }

    Write-Output $resource
}


function AddSqlFirewallRule()
{
    $myClientIp = ((Invoke-WebRequest -uri "http://ifconfig.me/ip").Content)
    Write-Output "Adding Client Ip Address $myClientIp to Sql Server Firewall"
    az sql server firewall-rule create --name "$env:ComputerName." --server $sqlServerName --resource-group $resourceGroupName --start-ip-address=$myClientIp --end-ip-address=$myClientIp
}

function CreateSqlDb()
{
    Write-Output "Sql Db $sqlDbName"

    $resource = (az sql db show --name $sqlDbName --server $sqlServerName --resource-group $resourceGroupName )
    if ($force -and $resource) {
        Write-Output "exists. deleting"
        az sql db delete --name $sqlDbName  --server $sqlServerName  --resource-group $resourceGroupName
        $resource = $null
    } 

    if (!$resource) {
        Write-Output "doesn't exist. creating"
        $resource = (az sql db create --name $sqlDbName  --server $sqlServerName  --resource-group $resourceGroupName --family Gen5 --edition "GeneralPurpose" --compute-model "Serverless" --capacity 1 --max-size "1GB")
    }

    Write-Output $resource
}

function CreateSqlServer()
{
    Write-Output "Sql Db $sqlServerName"

    $resource = (az sql server show --name $sqlServerName --resource-group $resourceGroupName )
    if ($force -and $resource) {
        Write-Output "exists. deleting"
        az sql server delete --name $sqlServerName  --resource-group $resourceGroupName
        $resource = $null
    } 

    if (!$resource) {
        Write-Output "doesn't exist. creating"
        $resource = (az sql server create --name $sqlServerName --resource-group $resourceGroupName --admin-password $sqlPassword --admin-user $sqlUsername --assign-identity --location $location)
    }

    Write-Output $resource
}

function CreateResourceGroup()
{
    Write-Output "Resource Group $resourceGroupName"

    $resourceGroup = (az group show --name $resourceGroupName)
    if ($force -and $resourceGroup) {
        Write-Output "exists. deleting"
        az group delete --name $resourceGroupName
        $resourceGroup = $null
    } 

    if (!$resourceGroup) {
        Write-Output " doesn't exist. creating"
        $resourceGroup = (az group create --name $resourceGroupName --tags Owner=$owner --location $location)
    }

    Write-Output $resourceGroup
}

if ($tearDown) { 
    $resourceGroup = (az group show --name $resourceGroupName)
    Write-Output "deleting"
    az group delete --name $resourceGroupName
    $resourceGroup = $null
    exit

} 

CreateResourceGroup
CreateSqlServer
CreateSqlDb
AddSqlFirewallRule
CreateContainerRegistry
UploadGrafanaImage
CreateAppServicePlan
CreateWebapp
CreateContainerInstance