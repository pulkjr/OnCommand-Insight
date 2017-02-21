<#
    .SYNOPSIS
    Retrieve LDAP configuration
    .DESCRIPTION
    Retrieve LDAP configuration
    .PARAMETER server
    OCI Server to connect to
#>
function Get-OciLdapConfiguration {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$False,
                   Position=0,
                   HelpMessage="OnCommand Insight Server.")]$Server=$CurrentOciServer
    )
 
    Begin {
        $Result = $null
        if (!$Server) {
            throw "Server parameter not specified and no global OCI Server available. Run Connect-OciServer first!"
        }
    }
   
    Process {
        $Uri = $Server.BaseUri + "/rest/v1/admin/ldap"
 
        try {
            $Result = Invoke-RestMethod -TimeoutSec $Server.Timeout -Method GET -Uri $Uri -Headers $Server.Headers
        }
        catch {
            $ResponseBody = ParseExceptionBody $_.Exception.Response
            Write-Error "GET to $Uri failed with Exception $($_.Exception.Message) `n $responseBody"
        }
 
        if (([String]$Result).Trim().startsWith('{') -or ([String]$Result).toString().Trim().startsWith('[')) {
            $Result = ParseJsonString($Result.Trim())
        }
        
        # add empty password to directoryLookup as this is not returned from OCI Server and is required for passing object to Update-OciLdapConfiguration
        $Result.directoryLookup | Add-Member -MemberType NoteProperty -Name password -Value "" -ErrorAction SilentlyContinue

        Write-Output $Result
    }
}