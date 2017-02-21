# TODO: Implement / Test testing of datasources
<#
    .SYNOPSIS
    Test Data Source
    .DESCRIPTION
    Empty POST body
    .PARAMETER id
    Id of data source to test
    .PARAMETER server
    OCI Server to connect to
#>
function Test-OciDatasource {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                   Position=0,
                   HelpMessage="Id of data source to test",
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
        $Uri = $Server.BaseUri + "/rest/v1/admin/datasources/$id/test"            
 
        if ($fromTime -or $toTime -or $expand) {
            $Uri += '?'
            $Separator = ''
            if ($fromTime) {
                $Uri += "fromTime=$($fromTime | ConvertTo-UnixTimestamp)"
                $Separator = '&'
            }
            if ($toTime) {
                $Uri += "$($Separator)toTime=$($toTime | ConvertTo-UnixTimestamp)"
                $Separator = '&'
            }
            if ($expand) {
                $Uri += "$($Separator)expand=$expand"
            }
        }
 
        try {
            if ('POST' -match 'PUT|POST') {
                Write-Verbose "Body: "
                $Result = Invoke-RestMethod -TimeoutSec $Server.Timeout -Method POST -Uri $Uri -Headers $Server.Headers -Body "" -ContentType 'application/json'
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