<#
    .SYNOPSIS
    Retrieve Datasource configuration.
    .DESCRIPTION
    Retrieve Datasource configuration.
    .PARAMETER id
    Id of data source to retrieve configuration for
    .PARAMETER server
    OCI Server to connect to
#>
function Get-OciDatasourceConfiguration {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                    Position=0,
                    HelpMessage="Id of data source to retrieve configuration for",
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)][Long[]]$id,
        [parameter(Mandatory=$False,
                   Position=1,
                   HelpMessage="OnCommand Insight Server.")]$Server=$CurrentOciServer
    )
 
    Begin {
        $Result = $null
        if (!$Server) {
            throw "Server parameter not specified and no global OCI Server available. Run Connect-OciServer first!"
        }
    }
   
    Process {
        $id = @($id)
        foreach ($id in $id) {
            $Uri = $Server.BaseUri + "/rest/v1/admin/datasources/$id/config"
 
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
            
            $DatasourceConfiguration = ParseDatasourceConfig($Result)
            Write-Output $DatasourceConfiguration
        }
    }
}