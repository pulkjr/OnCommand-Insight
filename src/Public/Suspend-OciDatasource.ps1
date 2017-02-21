# TODO: Implement / Check suspending of datasources
<#
    .SYNOPSIS
    Postpone one Data Source
    .DESCRIPTION
    Input body: { "days": value }
    .PARAMETER id
    Id of data source to postpone
    .PARAMETER Days
    Number of days to postpone datasource polling
    .PARAMETER server
    OCI Server to connect to
#>
function Suspend-OciDatasource {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                    Position=0,
                    HelpMessage="Id of data source to postpone",
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)][Long[]]$id,
        [parameter(Mandatory=$True,
                    Position=1,
                    HelpMessage="Number of days to postpone datasource polling")][Long]$Days,
        [parameter(Mandatory=$False,
                   Position=2,
                   HelpMessage="OnCommand Insight Server.")]$Server=$CurrentOciServer
    )
 
    Begin {
        $Result = $null
        if (!$Server) {
            throw "Server parameter not specified and no global OCI Server available. Run Connect-OciServer first!"
        }

        $switchparameters=@()
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
            $Uri = $Server.BaseUri + "/rest/v1/admin/datasources/$id/postpone"
 
            try {
                if ('POST' -match 'PUT|POST') {
                    Write-Verbose "Body: {`"days`":$days}"
                    $Result = Invoke-RestMethod -TimeoutSec $Server.Timeout -Method POST -Uri $Uri -Headers $Server.Headers -Body "{`"days`":$days}" -ContentType 'application/json'
                }
                else {
                    $Result = Invoke-RestMethod -TimeoutSec $Server.Timeout -Method POST -Uri $Uri -Headers $Server.Headers
                }
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
}