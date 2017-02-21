<#
    .SYNOPSIS
    Remove a Datasource
    .DESCRIPTION
    Remove a Datasource
    .PARAMETER id
    Id of data source to remove
    .PARAMETER acquisitionUnit
    Return related Acquisition unit
    .PARAMETER note
    Return related Note
    .PARAMETER changes
    Return list of related Changes
    .PARAMETER packages
    Return list of related Packages
    .PARAMETER activePatch
    Return related Active patch
    .PARAMETER events
    Return list of related Events
    .PARAMETER devices
    Return list of related Devices
    .PARAMETER config
    Return related Config
    .PARAMETER server
    OCI Server to connect to
#>
function Remove-OciDatasource {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                    Position=0,
                    HelpMessage="Id of data source to remove",
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
            $Uri = $Server.BaseUri + "/rest/v1/admin/datasources/$id"
 
            try {
                $Result = Invoke-RestMethod -TimeoutSec $Server.Timeout -Method DELETE -Uri $Uri -Headers $Server.Headers
            }
            catch {
                $ResponseBody = ParseExceptionBody $_.Exception.Response
                Write-Error "DELETE to $Uri failed with Exception $($_.Exception.Message) `n $responseBody"
            }
 
            if (([String]$Result).Trim().startsWith('{') -or ([String]$Result).toString().Trim().startsWith('[')) {
                $Result = ParseJsonString($Result.Trim())
            }
           
            $Datasource = ParseDatasources($Result)
            Write-Output $Datasource
        }
    }
}