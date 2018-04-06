[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)][string]$Key,
    [parameter(Mandatory=$true)][string]$Secret,
    [string]$Endpoint = "https://api.godaddy.com/v1",
    [parameter(Mandatory=$true)][string]$Domain,
    [parameter(Mandatory=$true)][string]$Subdomain,
    [int]$TTL = 3600,
    [string]$OverrideIP,
    [switch]$ForceUpdate
)

function Get-PublicIP {
    $ipinfo = Invoke-RestMethod "http://ipinfo.io/json"
    Return $ipinfo.ip
}

function Check-Update([string]$newIP) {
    try {
        $currentIP = [System.Net.Dns]::GetHostAddresses("$Subdomain.$Domain").IPAddressToString
        if ($currentIP -eq $newIP) {
            Write-Host "Remote IP is the same, no need to update."
            Return $false
        } else {
            Write-Verbose "Remote IP is different ($currentIP != $newIP)"
        }
    } catch {
        Write-Host "Unable to resolve remote IP. (Error: $($_.Exception.Message)) Continuing..."
    }
    Return $true
}

function Update-GodaddySubdomain([string]$Name, [string]$IP, [int]$TTL, [string]$Key, [string]$Secret) {
    $data="[{`"type`":`"A`", `"name`": `"$Name`", `"data`":`"$IP`",`"ttl`":$TTL}]"
    Write-Verbose "`$data = $data"

    $headers = @{
        Authorization = "sso-key $($Key):$($Secret)"
        Accept = "application/json"
        'Content-Type' = "application/json"
    }

    try {
        Invoke-WebRequest -Method Patch -Body "$data" `
            -Headers $headers `
            -Uri "$Endpoint/domains/$Domain/records"
    } catch {
        Write-Host "Failed to update. $($_.Exception.Message)"
    }
}


if ([string]::IsNullOrWhiteSpace($OverrideIP)) {
    Write-Verbose "Get public IP"
    $newIP = Get-PublicIP
} else {
    Write-Verbose "Overriding public IP with $OverrideIP"
    $newIP = $OverrideIP
}

if ($ForceUpdate -Or (Check-Update -newIP $newIP)) {
    Update-GodaddySubdomain -Name "$Subdomain.$Domain" -IP $newIP -TTL $TTL -Key $Key -Secret $Secret
}
