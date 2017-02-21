<#
    .SYNOPSIS
    Get patch
    .DESCRIPTION
    Get patch
    .PARAMETER id
    Id of a patch to retrieve
    .PARAMETER expand
    Expand parameter for underlying JSON object (e.g. expand=read,items)
    .PARAMETER datasourceConclusions
    Return list of related Patched datasources status
    .PARAMETER server
    OCI Server to connect to
#>
function Get-OciPatch {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                    Position=0,
                    HelpMessage="Id of a patch to retrieve",
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)][Long[]]$id,
        [parameter(Mandatory=$False,
                    Position=1,
                    HelpMessage="Expand parameter for underlying JSON object (e.g. expand=read,items)")][String]$expand,
        [parameter(Mandatory=$False,
                    Position=2,
                    HelpMessage="Return list of related Patched datasources status")][Switch]$datasourceConclusions,
        [parameter(Mandatory=$False,
                   Position=3,
                   HelpMessage="OnCommand Insight Server.")]$Server=$CurrentOciServer
    )
 
    Begin {
        $Result = $null
        if (!$Server) {
            throw "Server parameter not specified and no global OCI Server available. Run Connect-OciServer first!"
        }

        $switchparameters=@("datasourceConclusions")
        foreach ($parameter in $switchparameters) {
            if ((Get-Variable $parameter).Value) {
                if ($expand) {
                    $expand += ",$($parameter -replace 'performancehistory','performance.history' -replace 'hostswitch','host')"
                }
                else {
                    $expand = $($parameter -replace 'performancehistory','performance.history' -replace 'hostswitch','host')
                }
            }
        }
    }
   
    Process {
        $id = @($id)
        foreach ($id in $id) {
            $Uri = $Server.BaseUri + "/rest/v1/admin/patches/$id"            
 
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