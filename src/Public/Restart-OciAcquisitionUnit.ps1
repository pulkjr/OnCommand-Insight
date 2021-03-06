<#
    .SYNOPSIS
    Restart an Acquisition Unit
    .DESCRIPTION
    Restart an Acquisition Unit
    .PARAMETER id
    ID of acquisition unit to restart
    .PARAMETER server
    OCI Server to connect to
#>
function Restart-OciAcquisitionUnit {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                    Position=0,
                    HelpMessage="Id of acquisition unit to restart",
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
            $Uri = $Server.BaseUri + "/rest/v1/admin/acquisitionUnits/$id/restart"
 
            try {
                $Result = Invoke-RestMethod -TimeoutSec $Server.Timeout -Method POST -Uri $Uri -Headers $Server.Headers
            }
            catch {
                $ResponseBody = ParseExceptionBody $_.Exception.Response
                Write-Error "POST to $Uri failed with Exception $($_.Exception.Message) `n $responseBody"
            }
 
            if (([String]$Result).Trim().startsWith('{') -or ([String]$Result).toString().Trim().startsWith('[')) {
                $Result = ParseJsonString($Result.Trim())
            }
       
            $AcquisitionUnit = ParseAcquisitionUnits($Result)
            Write-Output $AcquisitionUnit
        }
    }
}