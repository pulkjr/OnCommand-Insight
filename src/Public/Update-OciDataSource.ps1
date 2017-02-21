<#
    .SYNOPSIS
    Update OCI Datasource
    .DESCRIPTION
    Update OCI Datasource
    .PARAMETER id
    Id of data source to update
    .PARAMETER name
    New name for datasource
    .PARAMETER acquisitionUnit
    New Acquisition unit to associated datasource with
    .PARAMETER config
    Updated configuration of datasources
    .PARAMETER server
    OCI Server to connect to
#>
function Update-OciDataSource {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                    Position=0,
                    HelpMessage="Id of data source to update",
                    ValueFromPipelineByPropertyName=$True)][Long]$id,
        [parameter(Mandatory=$False,
                    Position=1,
                    HelpMessage="Datasource name",
                    ValueFromPipelineByPropertyName=$True)][String]$name,
        [parameter(Mandatory=$False,
                    Position=2,
                    HelpMessage="Datasource acquisition unit",
                    ValueFromPipelineByPropertyName=$True)][PSObject]$acquisitionUnit,
        [parameter(Mandatory=$False,
                    Position=3,
                    HelpMessage="Datasource configuration",
                    ValueFromPipelineByPropertyName=$True)][PSObject]$config,
        [parameter(Mandatory=$False,
                   Position=4,
                   HelpMessage="OnCommand Insight Server.")]$Server=$CurrentOciServer
    )
 
    Begin {
        $Result = $null
        if (!$Server) {
            throw "Server parameter not specified and no global OCI Server available. Run Connect-OciServer first!"
        }
    }
   
    Process {
        $Uri = $Server.BaseUri + "/rest/v1/admin/datasources/$id"
 
        try {
            $Body = @{}
            if ($Name) { 
                $Body.name = $Name 
            }
            if ($acquisitionUnit) { 
                $Body.acquisitionUnit = $acquisitionUnit | select -property id
            }
            if ($config) {
                $ConfigScriptProperties = $config.PSObject.Members | ? { $_.MemberType -eq "ScriptProperty" } | % { $_.Name }
                if (!$config.foundation.attributes.password) {
                    $config.foundation.attributes.PSObject.Properties.Remove('password')
                }
                if (!$config.foundation.attributes.'partner.password') {
                    $config.foundation.attributes.PSObject.Properties.Remove('partner.password')
                }
                $Body.config = $config | Select -Property * -ExcludeProperty $ConfigScriptProperties
                $Uri += "?expand=config"
            }
            $Body = $Body | ConvertTo-Json -Depth 10
            Write-Verbose "Body: $Body"
            $Result = Invoke-RestMethod -TimeoutSec $Server.Timeout -Method PATCH -Uri $Uri -Headers $Server.Headers -Body $Body -ContentType 'application/json'
            if ($Result.toString().startsWith('{')) {
                $Result = ParseJsonString($Result)
            }
        }
        catch {
            $ResponseBody = ParseExceptionBody $_.Exception.Response
            Write-Error "PATCH to $Uri failed with Exception $($_.Exception.Message) `n $responseBody"
        }
       
        $Datasource = ParseDatasources($Result)
        if ($Datasource.config.packages) {
            $config.packages = $Datasource.config.packages
        }
        Write-Output $Datasource
    }
}