# login.ps1
# Idempotent Azure login script.
# If service principal env vars exist it will use them. Otherwise it will attempt device auth interactively.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Log {
    param([string]$m)
    Write-Host $m
}

# If Az module is not available, warn and exit early
if (-not (Get-Module -ListAvailable -Name Az)) {
    Write-Log "Az module not found in session. The postCreate step should have installed it. You can run: Install-Module -Name Az -Scope CurrentUser -Force -Repository PSGallery -AllowClobber"
}

# If already logged in, do nothing
try {
    $ctx = Get-AzContext -ErrorAction SilentlyContinue
} catch {
    $ctx = $null
}

if ($null -ne $ctx -and $ctx.Account -ne $null) {
    Write-Log "Azure context already active for account $($ctx.Account.Id)."
    return
}

# Use service principal when environment variables are present
if ($env:AZURE_CLIENT_ID -and $env:AZURE_CLIENT_SECRET -and $env:AZURE_TENANT_ID -and $env:AZURE_SUBSCRIPTION_ID) {
    try {
        Write-Log "Logging in with Service Principal..."
        $securePwd = ConvertTo-SecureString $env:AZURE_CLIENT_SECRET -AsPlainText -Force
        $creds = New-Object System.Management.Automation.PSCredential ($env:AZURE_CLIENT_ID, $securePwd)

        Connect-AzAccount -ServicePrincipal -Credential $creds -Tenant $env:AZURE_TENANT_ID -ErrorAction Stop | Out-Null

        Select-AzSubscription -SubscriptionId $env:AZURE_SUBSCRIPTION_ID -ErrorAction Stop

        Write-Log "Azure context set to subscription $($env:AZURE_SUBSCRIPTION_ID)"
        Write-Log ">>> Azure login script executed at $(Get-Date -Format o)"
    } catch {
        Write-Log "Service Principal login failed: $($_.Exception.Message)"
    }
    return
}

# Fallback: interactive device authentication
try {
    Write-Log "Service principal env vars not detected. Falling back to device authentication. Follow the instructions in the terminal to complete login."
    Connect-AzAccount -UseDeviceAuthentication -ErrorAction Stop | Out-Null
    if ($env:AZURE_SUBSCRIPTION_ID) {
        try {
            Select-AzSubscription -SubscriptionId $env:AZURE_SUBSCRIPTION_ID -ErrorAction SilentlyContinue
        } catch {}
    }
    Write-Log "Interactive login complete."
} catch {
    Write-Log "Interactive login failed or was cancelled: $($_.Exception.Message)"
}
