<#
.EXAMPLE
Connect-OciServer -Name ociserver.example.com -Credential (Get-Credential)

Name       : ociserver.example.com
BaseURI    : https://ociserver.example.com
Credential : System.Management.Automation.PSCredential
Headers    : {Authorization}
APIVersion : 1.3
Timezone   : (UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
#>
function Connect-OciServer {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                   Position=0,
                   HelpMessage="The name of the OCI Server. This value may also be a string representation of an IP address. If not an address, the name must be resolvable to an address.")][String]$Name,
        [parameter(Mandatory=$True,
                   Position=1,
                   HelpMessage="A System.Management.Automation.PSCredential object containing the credentials needed to log into the OCI server.")][System.Management.Automation.PSCredential]$Credential,
        [parameter(Mandatory=$False,
                   Position=2,
                   HelpMessage="This cmdlet always tries to establish a secure HTTPS connection to the OCI server, but it will fall back to HTTP if necessary. Specify -HTTP to skip the HTTPS connection attempt and only try HTTP.")][Switch]$HTTP,
        [parameter(Mandatory=$False,
                   Position=2,
                   HelpMessage="This cmdlet always tries to establish a secure HTTPS connection to the OCI server, but it will fall back to HTTP if necessary. Specify -HTTPS to fail the connection attempt in that case rather than fall back to HTTP.")][Switch]$HTTPS,
        [parameter(Mandatory=$False,
                   Position=3,
                   HelpMessage="If the OCI server certificate cannot be verified, the connection will fail. Specify -Insecure to ignore the validity of the OCI server certificate.")][Switch]$Insecure,
        [parameter(Position=4,
                   Mandatory=$False,
                   HelpMessage="Specify -Transient to not set the global variable `$CurrentOciServer.")][Switch]$Transient,
        [parameter(Mandatory=$False,
                   Position=5,
                   HelpMessage="As the timezone of the OCI Server is not available via the REST API, it needs to be manually set so that all timestamps are displayed with the correct timezone. By default the timezone will be set to the local timezone of the PowerShell environment.")][PSObject]$Timezone,
        [parameter(Mandatory=$False,
                   Position=6,
                   HelpMessage="Timeout value for HTTP connections. Defaults to 600 seconds.")][Int]$Timeout
    )
 
    $EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password)
    $EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
    $Headers = @{"Authorization"="Basic $($EncodedPassword)"}
 
    # check if untrusted SSL certificates should be ignored
    if ($Insecure) {
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        }
        else {
            if (!"Invoke-RestMethod:SkipCertificateCheck") {
                $PSDefaultParameterValues.Add("Invoke-RestMethod:SkipCertificateCheck",$true)
            }
            else {
                $PSDefaultParameterValues.'Invoke-RestMethod:SkipCertificateCheck'=$true
            }
        }
    }

    # TODO: Remove as soon as PowerShell 6 fixes OSVersion implementation
    try {
        if ([environment]::OSVersion.Platform -match "Win") {
            # check if proxy is used
            $ProxyRegistry = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
            $ProxySettings = Get-ItemProperty -Path $ProxyRegistry
            if ($ProxySettings.ProxyEnable) {
                Write-Warning "Proxy Server $($ProxySettings.ProxyServer) configured in Internet Explorer may be used to connect to the OCI server!"
            }
            if ($ProxySettings.AutoConfigURL) {
                Write-Warning "Proxy Server defined in automatic proxy configuration script $($ProxySettings.AutoConfigURL) configured in Internet Explorer may be used to connect to the OCI server!"
            }
        }
    }
    catch {}
 
    if ($HTTPS -or !$HTTP) {
        Try {
            $BaseURI = "https://$Name"
            $Response = Invoke-RestMethod -Method Post -Uri "$BaseURI/rest/v1/login" -TimeoutSec $Timeout -Headers $Headers
            $APIVersion = $Response.apiVersion
        }
        Catch {
            $ResponseBody = ParseExceptionBody $_.Exception.Response
            if ($_.Exception.Message -match "Unauthorized") {
                Write-Error "Authorization for $BaseURI/rest/v1/login with user $($Credential.UserName) failed"
                return
            }
            else {
                if ($HTTPS) {
                    Write-Error "Login to $BaseURI/rest/v1/login failed via HTTPS protocol, but HTTPS was enforced. Exception $($_.Exception.Message)`n $ResponseBody"
                    return
                }
                else {
                    Write-Warning "Login to $BaseURI/rest/v1/login failed via HTTPS protocol. Exception message: $($_.Exception.Message)`n $ResponseBody"
                    $HTTP = $True
                }
            }
        }
    }

    if ($HTTP) {
        Try {
            $BaseURI = "http://$Name"
            $Response = Invoke-RestMethod -Method Post -Uri "$BaseURI/rest/v1/login" -TimeoutSec $Timeout -Headers $Headers
            $APIVersion = $Response.apiVersion
        }
        Catch {
            $ResponseBody = ParseExceptionBody $_.Exception.Response
            if ($_.Exception.Message -match "Unauthorized") {                
                Write-Error "Authorization for $BaseURI/rest/v1/login with user $($Credential.UserName) failed"
                return
            }
            else {
                Write-Error "Login to $BaseURI/rest/v1/login failed via HTTP protocol. Exception message: $($_.Exception.Message)`n $ResponseBody"
                return
            }
        }
    }

    if (!$Timezone) {
        $Timezone = [System.TimeZoneInfo]::Local
    }
    
    if ($Timezone -isnot [System.TimeZoneInfo]) {
        if ([System.TimeZoneInfo]::GetSystemTimeZones().Id -contains $Timezone) {
            $Timezone = [System.TimeZoneInfo]::GetSystemTimeZones() | ? { $_.Id -contains $Timezone }
        }
        else {
            Write-Warning "Timezone $Timezone is not supported by this system. Setting Timezone to $([System.TimeZoneInfo]::Local)"
            $Timezone = [System.TimeZoneInfo]::Local
        }
    }

    if (!$Timeout) {
        $Timeout = 600
    }
 
    $Server = New-Object -TypeName psobject
    $Server | Add-Member -MemberType NoteProperty -Name Name -Value $Name
    $Server | Add-Member -MemberType NoteProperty -Name BaseURI -Value $BaseURI
    $Server | Add-Member -MemberType NoteProperty -Name Credential -Value $Credential
    $Server | Add-Member -MemberType NoteProperty -Name Headers -Value $Headers
    $Server | Add-Member -MemberType NoteProperty -Name APIVersion -Value $APIVersion
    $Server | Add-Member -MemberType NoteProperty -Name Timezone -Value $Timezone
    $Server | Add-Member -MemberType NoteProperty -Name Timeout -Value $Timeout
 
    if (!$Transient) {
        Set-Variable -Name CurrentOciServer -Value $Server -Scope Global
    }
 
    return $Server
}