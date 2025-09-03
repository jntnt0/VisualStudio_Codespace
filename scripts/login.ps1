Write-Host "Logging into Azure with Service Principal..."

$securePwd = ConvertTo-SecureString $env:AZURE_CLIENT_SECRET -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($env:AZURE_CLIENT_ID, $securePwd)

Connect-AzAccount -ServicePrincipal -Credential $creds -Tenant $env:AZURE_TENANT_ID | Out-Null
Select-AzSubscription -SubscriptionId $env:AZURE_SUBSCRIPTION_ID

Write-Host "Azure context set to subscription $($env:AZURE_SUBSCRIPTION_ID)"
Write-Host ">>> Azure login script executed at $(Get-Date)"
