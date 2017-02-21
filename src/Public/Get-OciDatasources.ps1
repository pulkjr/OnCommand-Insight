<#
    .SYNOPSIS
    Retrieve all Data Sources
    .DESCRIPTION
    Retrieve all Data Sources
    .PARAMETER expand
    Expand parameter for underlying JSON object (e.g. expand=acquisitionUnit)
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
function Get-OciDatasources {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$False,
                    Position=0,
                    HelpMessage="Expand parameter for underlying JSON object (e.g. expand=acquisitionUnit)")][String]$expand,
        [parameter(Mandatory=$False,
                    Position=1,
                    HelpMessage="Return related Acquisition unit")][Switch]$acquisitionUnit,
        [parameter(Mandatory=$False,
                    Position=2,
                    HelpMessage="Return related Note")][Switch]$note,
        [parameter(Mandatory=$False,
                    Position=3,
                    HelpMessage="Return list of related Changes")][Switch]$changes,
        [parameter(Mandatory=$False,
                    Position=4,
                    HelpMessage="Return list of related Packages")][Switch]$packages,
        [parameter(Mandatory=$False,
                    Position=5,
                    HelpMessage="Return related Active patch")][Switch]$activePatch,
        [parameter(Mandatory=$False,
                    Position=6,
                    HelpMessage="Return list of related Events")][Switch]$events,
        [parameter(Mandatory=$False,
                    Position=7,
                    HelpMessage="Return list of related Devices")][Switch]$devices,
        [parameter(Mandatory=$False,
                    Position=8,
                    HelpMessage="Return related Config")][Switch]$config,
        [parameter(Mandatory=$False,
                   Position=9,
                   HelpMessage="OnCommand Insight Server.")]$Server=$CurrentOciServer
    )
 
    Begin {
        $Result = $null
        if (!$Server) {
            throw "Server parameter not specified and no global OCI Server available. Run Connect-OciServer first!"
        }

        $switchparameters=@("acquisitionUnit","note","changes","packages","activePatch","events","devices","config")
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
            $Uri = $Server.BaseUri + "/rest/v1/admin/datasources"
 
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
           
            $Datasources = ParseDatasources($Result)
            Write-Output $Datasources
        }
    }
}