# TODO: Implement / Test LDAP connection test
<#
    .SYNOPSIS
    Perform an LDAP connection test
    .PARAMETER server
    OCI Server to connect to
#>
function Test-OciLdapConfiguration {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                   Position=0,
                   HelpMessage="LDAP Server URL",
                   ValueFromPipelineByPropertyName=$True)][String]$LdapServer,
        [parameter(Mandatory=$True,
                   Position=1,
                   HelpMessage="User name to use for LDAP test",
                   ValueFromPipelineByPropertyName=$True)][String]$UserName,
        [parameter(Mandatory=$True,
                   Position=2,
                   HelpMessage="The password of the user for the LDAP test",
                   ValueFromPipelineByPropertyName=$True)][PSCustomObject]$Password,
        [parameter(Mandatory=$False,
                   Position=3,
                   HelpMessage="OnCommand Insight Server.")]$Server=$CurrentOciServer
    )
 
    Begin {
        $Result = $null
        if (!$Server) {
            throw "Server parameter not specified and no global OCI Server available. Run Connect-OciServer first!"
        }
    }
   
    Process {
        $Uri = $Server.BaseUri + "/rest/v1/admin/ldap/test"            
 
        try {
            $Body = ConvertTo-Json -InputObject @{"server"=$LdapServer;"userName"=$UserName;"password"=$Password} -Compress
            Write-Verbose "Body: $Body"
            $Result = Invoke-RestMethod -TimeoutSec $Server.Timeout -Method POST -Uri $Uri -Headers $Server.Headers -Body $Body -ContentType 'application/json'
        }
        catch {
            $ResponseBody = ParseExceptionBody $_.Exception.Response
            Write-Error "POST to $Uri failed with Exception $($_.Exception.Message) `n $responseBody"
        }
 
        if (([String]$Result).Trim().startsWith('{') -or ([String]$Result).toString().Trim().startsWith('[')) {
            $Result = ParseJsonString($Result.Trim())
        }
           
        Write-Output $Result
    }
}