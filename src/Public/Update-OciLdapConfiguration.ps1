<#
    .SYNOPSIS
    Update LDAP config
    .DESCRIPTION
    .PARAMETER server
    OCI Server to connect to
#>
function Update-OciLdapConfiguration {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                   Position=0,
                   HelpMessage="Enable LDAP Configuration",
                   ValueFromPipelineByPropertyName=$True)][Boolean]$isEnabled=$true,
        [parameter(Mandatory=$True,
                   Position=1,
                   HelpMessage="Directory Lookup configuration. Hash containing key,value pairs for server, timeout, referral, userName, password and domain. Example: @{'server'='ldap://','timeout'=2000,'referral'='follow','userName'='directoryLookupUserName','domain'='DC=domain,DC=com'}",
                   ValueFromPipelineByPropertyName=$True)][PSCustomObject]$DirectoryLookup,
        [parameter(Mandatory=$True,
                   Position=2,
                   HelpMessage="LDAP Groups configuration. Hash containing LDAP groups as key,value pairs for users, guests, admins and serverAdmins. Example: @{'users'='insight.users','guests'='insight.guests','admins'='insight.admins','serverAdmins'='insight.server.admins'}",
                   ValueFromPipelineByPropertyName=$True)][PSCustomObject]$Groups,
        [parameter(Mandatory=$True,
                   Position=3,
                   HelpMessage="LDAP Attribute configuration. Hash containing LDAP attributes as key,value pairs for role, mail, userPrincipalName and distinguishedName. Example: @{'role'='memberOf','mail'='mail','userPrincipalName'='userPrincipalName','distinguishedName'='distinguishedName'}",
                   ValueFromPipelineByPropertyName=$True)][PSCustomObject]$Attributes,
        [parameter(Mandatory=$False,
                   Position=15,
                   HelpMessage="OnCommand Insight Server.")]$Server=$CurrentOciServer
    )
 
    Begin {
        $Result = $null
        if (!$Server) {
            throw "Server parameter not specified and no global OCI Server available. Run Connect-OciServer first!"
        }
    }
   
    Process {
        $Uri = $Server.BaseUri + "/rest/v1/admin/ldap"           
 
        try {
            $Input = @{"isEnabled"=$isEnabled;
                        "directoryLookup"=$DirectoryLookup;
                        "groups"=$Groups;
                        "attributes"=$Attributes}
            $Body = ConvertTo-Json -InputObject $Input -Compress
            Write-Verbose "Body: $Body"
            $Result = Invoke-RestMethod -TimeoutSec $Server.Timeout -Method PUT -Uri $Uri -Headers $Server.Headers -Body $Body -ContentType 'application/json'
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