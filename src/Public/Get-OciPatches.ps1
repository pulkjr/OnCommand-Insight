<#
    .SYNOPSIS
    Retrieve all patches
    .DESCRIPTION
    Retrieve all patches
    .PARAMETER expand
    Expand parameter for underlying JSON object (e.g. expand=read,items)
    .PARAMETER datasourceConclusions
    Return related datasource status
    .PARAMETER server
    OCI Server to connect to
#>
function Get-OciPatches {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$False,
                    Position=0,
                    HelpMessage="Expand parameter for underlying JSON object (e.g. expand=read,items)")][String]$expand,
        [parameter(Mandatory=$False,
                    Position=1,
                    HelpMessage="Return related datasource status")][Switch]$datasourceConclusions,
        [parameter(Mandatory=$False,
                   Position=2,
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
        $Uri = $Server.BaseUri + "/rest/v1/admin/patches"        
 
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