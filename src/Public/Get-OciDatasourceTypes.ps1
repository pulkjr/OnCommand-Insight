<#
    .SYNOPSIS
    Retrieve all data source types.
    .DESCRIPTION
    Retrieve all data source types.
    .PARAMETER server
    OCI Server to connect to
#>
function Get-OciDatasourceTypes {
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
        $Uri = $Server.BaseUri + "/rest/v1/admin/datasourceTypes"
 
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
       
        $DatasourceTypes = ParseDatasourceTypes($Result)
        Write-Output $DatasourceTypes
    }
}