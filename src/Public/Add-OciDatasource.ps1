<#
    .SYNOPSIS
    Add Data Source
    .DESCRIPTION
    Add Data Source    
    .PARAMETER name
    Datasource name
    .PARAMETER acquisitionUnit
    Acquisition unit to associated datasource with
    .PARAMETER config
    Configuration of datasource
    .PARAMETER server
    OCI Server to connect to
#>
function Add-OciDatasource {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                    Position=0,
                    HelpMessage="Datasource name",
                    ValueFromPipelineByPropertyName=$True)][String]$name,
        [parameter(Mandatory=$True,
                    Position=1,
                    HelpMessage="Datasource acquisition unit",
                    ValueFromPipelineByPropertyName=$True)][PSObject]$acquisitionUnit,
        [parameter(Mandatory=$True,
                    Position=2,
                    HelpMessage="Datasource configuration",
                    ValueFromPipelineByPropertyName=$True)][PSObject]$config,
        [parameter(Mandatory=$False,
                   Position=3,
                   HelpMessage="OnCommand Insight Server.")]$Server=$CurrentOciServer
    )
 
    Begin {
        $Result = $null
        if (!$Server) {
            throw "Server parameter not specified and no global OCI Server available. Run Connect-OciServer first!"
        }
    }
   
    Process {
        $Uri = $Server.BaseUri + "/rest/v1/admin/datasources"
 
        try {
            $Body = @{}
            if ($Name) { 
                $Body.name = $Name 
            }
            if ($acquisitionUnit) {
                if ($acquisitionUnit -is [int]) {
                    $Body.acquisitionUnit = @{id=$acquisitionUnit}
                }
                elseif ($acquisitionUnit.id) {
                    $Body.acquisitionUnit = $acquisitionUnit | select -property id
                }
            }
            if ($config) {
                $ConfigScriptProperties = $config.PSObject.Members | ? { $_.MemberType -eq "ScriptProperty" } | % { $_.Name }
                $Body.config = $config | Select -Property * -ExcludeProperty $ConfigScriptProperties
                $Uri += "?expand=config"
            }
            $Body = $Body | ConvertTo-Json -Depth 10
            Write-Verbose "Body: $Body"
            $Result = Invoke-RestMethod -TimeoutSec $Server.Timeout -Method POST -Uri $Uri -Headers $Server.Headers -Body $Body -ContentType 'application/json'
            if ($Result.toString().startsWith('{')) {
                $Result = ParseJsonString($Result)
            }
        }
        catch {
            $ResponseBody = ParseExceptionBody $_.Exception.Response
            Write-Error "POST to $Uri failed with Exception $($_.Exception.Message) `n $responseBody"
        }
       
        $Datasource = ParseDatasources($Result)
        Write-Output $Datasource
    }
}