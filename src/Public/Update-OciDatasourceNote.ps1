# TODO: Check and implement updating of datasource note
<#
    .SYNOPSIS
    Update one Data Source note
    .DESCRIPTION
    Request body should be like JSON below: <br/>

    <pre>
    {
        "value":"My Note"
    }
    </pre>
            
    .PARAMETER id
    Id of data source to update
    .PARAMETER value
    Note to be added to datasource
    .PARAMETER server
    OCI Server to connect to
#>
function Update-OciDatasourceNote {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                    Position=0,
                    HelpMessage="Id of data source to update",
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)][Long[]]$id,
        [parameter(Mandatory=$True,
                    Position=1,
                    HelpMessage="Note to be added to datasource")][String]$value,
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
            $Uri = $Server.BaseUri + "/rest/v1/admin/datasources/$id/note"
 
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
                if ('PUT' -match 'PUT|POST') {
                    Write-Verbose "Body: {`"value`":$value}"
                    $Result = Invoke-RestMethod -TimeoutSec $Server.Timeout -Method PUT -Uri $Uri -Headers $Server.Headers -Body "{`"value`":$value}" -ContentType 'application/json'
                }
                else {
                    $Result = Invoke-RestMethod -TimeoutSec $Server.Timeout -Method PUT -Uri $Uri -Headers $Server.Headers
                }
            }
            catch {
                $ResponseBody = ParseExceptionBody $_.Exception.Response
                Write-Error "PUT to $Uri failed with Exception $($_.Exception.Message) `n $responseBody"
            }
 
            if (([String]$Result).Trim().startsWith('{') -or ([String]$Result).toString().Trim().startsWith('[')) {
                $Result = ParseJsonString($Result.Trim())
            }
           
            Write-Output $Result
        }
    }
}