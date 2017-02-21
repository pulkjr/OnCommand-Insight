# TODO: Implement uploading of certificates
<#
    .SYNOPSIS
    Add a certificate based on source host/port or certificate file
    .DESCRIPTION
    User can add certificate for LDAP based on either source host/port or certificate file. Two ways to create certificate are supported: <br/>

To create from host and port use:
<pre>
{
    "host": "localhost",
    "port": 389
}
</pre>

To create from existing certificate file create a multi part request with the attributes:
<pre>
    alias: the alias for certificate in store
    certificateFile: the actual file to load into store
</pre>
    .PARAMETER server
    OCI Server to connect to
#>
function Add-OciCertificate {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                   Position=0,
                   ParameterSetName='host',
                   HelpMessage="LDAP URI (e.g. dc1.example.com)")][String]$HostName,
        [parameter(Mandatory=$False,
                   Position=1,
                   ParameterSetName='host',
                   HelpMessage="LDAP SSL Port")][Int]$Port=636,
        [parameter(Mandatory=$True,
                   Position=0,
                   ParameterSetName='file',
                   HelpMessage="OnCommand Insight Server.")][String]$Alias,
        [parameter(Mandatory=$True,
                   Position=1,
                   ParameterSetName='file',
                   HelpMessage="OnCommand Insight Server.")][String]$File,
        [parameter(Mandatory=$False,
                   Position=2,
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
            $Uri = $Server.BaseUri + "/rest/v1/admin/certificates"
 
            try {
                $Body = ConvertTo-Json @{"host"=$HostName;"port"=$Port} -Compress
                Write-Verbose "Body: $Body"
                $Result = Invoke-RestMethod -TimeoutSec $Server.Timeout -Method POST -Uri $Uri -Headers $Server.Headers -Body $Body -ContentType 'application/json'
            }
            catch {
                $ResponseBody = ParseExceptionBody $_.Exception.Response
                Write-Error "POST to $Uri failed with Exception $($_.Exception.Message) `n $responseBody"
            }
 
            if (([String]$Result).Trim().startsWith('{') -or ([String]$Result).toString().Trim().startsWith('[')) {
                $Result = ParseJsonString($Result.Trim())
            }
       
            $Certificate = ParseCertificate($Result)
            Write-Output $Certificate
        }
    }
}