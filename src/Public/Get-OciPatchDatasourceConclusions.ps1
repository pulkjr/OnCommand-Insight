<#
    .SYNOPSIS
    Retrieve Patch Data Source Conclusions
    .DESCRIPTION
    Retrieve Patch Data Source Conclusions
    .PARAMETER id
    Id of patch to get data source conslusions for
    .PARAMETER expand
    Expand parameter for underlying JSON object (e.g. expand=read,items)
    .PARAMETER server
    OCI Server to connect to
#>
function Get-OciPatchDatasourceConclusions {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                    Position=0,
                    HelpMessage="Id of patch to get data source conslusions for",
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)][Long[]]$id,
        [parameter(Mandatory=$False,
                    Position=1,
                    HelpMessage="Expand parameter for underlying JSON object (e.g. expand=read,items)")][String]$expand,
        [parameter(Mandatory=$False,
                   Position=2,
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
            $Uri = $Server.BaseUri + "/rest/v1/admin/patches/$id/datasourceConclusions"
 
            if ($expand) {
                $Uri += "?$($Separator)expand=$expand"
            }
 
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
           
            Write-Output $Result
        }
    }
}