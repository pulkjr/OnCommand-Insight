<#
    .SYNOPSIS
    New Data Source
    .DESCRIPTION
    Create new Data Source from type definition  
    .PARAMETER type
    Datasource type 
    .PARAMETER name
    Name of the datasource
    .PARAMETER acquisitionUnit
    Acquisition unit to associated datasource with
    .PARAMETER server
    OCI Server to connect to
#>
function New-OciDatasource {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                    Position=0,
                    HelpMessage="Datasource type",
                    ValueFromPipelineByPropertyName=$True)][PSObject]$type,
        [parameter(Mandatory=$True,
                    Position=1,
                    HelpMessage="Datasource name",
                    ValueFromPipelineByPropertyName=$True)][String]$name,
        [parameter(Mandatory=$True,
                    Position=2,
                    HelpMessage="Datasource acquisition unit",
                    ValueFromPipelineByPropertyName=$True)][PSObject]$acquisitionUnit
    )
   
    Process {
        
        $Datasource = [PSCustomObject]@{name=$Name;acquisitionUnit=[PSCustomObject]@{}}

        $Datasource | Add-Member -MemberType NoteProperty -Name "config" -Value ([PSCustomObject]@{})
        
        if ($acquisitionUnit -is [int]) {
            $Datasource.acquisitionUnit | Add-Member -MemberType NoteProperty -Name "id" -value $acquisitionUnit
        }
        elseif ($acquisitionUnit.id) {
            $Datasource.acquisitionUnit = $acquisitionUnit | select -property id
        }

        $Datasource.config | Add-Member -MemberType NoteProperty -Name "dsTypeId" -Value $type.id
        $Datasource.config | Add-Member -MemberType NoteProperty -Name "vendor" -Value $type.vendorModels.vendorDescription
        $Datasource.config | Add-Member -MemberType NoteProperty -Name "model" -Value $type.vendorModels.modelDescription
        $Datasource.config | Add-Member -MemberType NoteProperty -Name "packages" -Value @()

        # if no packages are specified, enable all packages of specified type
        if ($packages) {
            $type.packages = $type.packages | ? { $packages -match $_.id }
        }

        foreach ($package in $type.packages) {
            $attributes = $package.attributes
            $package = [PSCustomObject]@{id=$package.id;displayName=$package.displayName;attributes=[PSCustomObject]@{}}
            foreach ($attribute in $attributes) {
                $package.attributes | Add-Member -MemberType NoteProperty -Name $attribute.name -Value $attribute.defaultValue
            }
            $Datasource.config.packages += $package
        }

        # parse datasource to make sure that script properties are created 
        $Datasource = ParseDatasources($Datasource)
        Write-Output $Datasource
    }
}