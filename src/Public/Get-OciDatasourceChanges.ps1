<#
    .SYNOPSIS
    Retrieve Data Source changes
    .DESCRIPTION
    Retrieve Data Source changes
    .PARAMETER id
    Id of data source to get data for
    .PARAMETER expand
    Expand parameter for underlying JSON object (e.g. expand=read,items)
    .PARAMETER details
    Return list of related Details
    .PARAMETER server
    OCI Server to connect to
#>
function Get-OciDatasourceChanges {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                    Position=0,
                    HelpMessage="Id of data source to get data for",
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)][Long[]]$id,
        [parameter(Mandatory=$False,
                    Position=1,
                    HelpMessage="Expand parameter for underlying JSON object (e.g. expand=read,items)")][String]$expand,
        [parameter(Mandatory=$False,
                    Position=2,
                    HelpMessage="Return list of related Details")][Switch]$details,
        [parameter(Mandatory=$False,
                   Position=3,
                   HelpMessage="OnCommand Insight Server.")]$Server=$CurrentOciServer
    )
 
    Begin {
        $Result = $null
        if (!$Server) {
            throw "Server parameter not specified and no global OCI Server available. Run Connect-OciServer first!"
        }

        $switchparameters=@("details")
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
            $Uri = $Server.BaseUri + "/rest/v1/admin/datasources/$id/changes"

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
           
            $Change = ParseChanges($Result)
            Write-Output $Change
        }
    }
}