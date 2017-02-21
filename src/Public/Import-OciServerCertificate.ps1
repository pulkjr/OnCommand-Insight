<#
    .SYNOPSIS
    Import OCI Server Certificate into Windows Certificate store
    .DESCRIPTION
    Import OCI Server Certificate into Windows Certificate store
    .PARAMETER CertificateStoreOwner
    Owner of the certificate store where the certificate should be stored.
    .PARAMETER Name
    The name of the OCI Server. This value may also be a string representation of an IP address. If not an address, the name must be resolvable to an address.
    .PARAMETER Server
    OCI Server to connect to
    .EXAMPLE
    Import-OciServerCertificate
#>
function Import-OciServerCertificate {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$False,
                   Position=0,
                   HelpMessage="Owner of the certificate store where the certificate should be stored.")][ValidateSet("CurrentUser","LocalMachine")][String]$CertificateStoreOwner="CurrentUser",
        [parameter(Mandatory=$False,
                   Position=1,
                   HelpMessage="The name of the OCI Server. This value may also be a string representation of an IP address. If not an address, the name must be resolvable to an address.")]$Name,
        [parameter(Mandatory=$False,
                   Position=2,
                   HelpMessage="OnCommand Insight Server.")]$Server=$CurrentOciServer
    )

    Begin {
        $Result = $null
        if (!$Server -and !$Name) {
            throw "Server and Name parameter not specified and no global OCI Server available. Use Name parameter or run Connect-OciServer first!"
        }
        if ($Name) {
            $Uri = "https://$Name"
        }
        else {
            $Uri = $Server.BaseUri
        }
        if ($CertificateStoreOwner -eq "LocalMachine" -and ![Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
            throw "Administrator privilige required to store certificate in LocalMachine certificate store"
        }
    }
   
    Process {
        $Request = [Net.HttpWebRequest]::Create($Uri)
        $Request.Method = "OPTIONS"

        try {
            $Response = $Request.GetResponse()
        }
        catch {
        }
 
        if (!$Request.ServicePoint.Certificate) {
            Write-Error "No Certificate returned for $Uri"
        }

        $Certificate = $Request.ServicePoint.Certificate

        Write-Verbose "Retrieved certificate with subject $($Certificate.Subject) from issuer $($Certificate.Issuer)"

        $CertificateStore = New-Object System.Security.Cryptography.X509Certificates.X509Store([System.Security.Cryptography.X509Certificates.StoreName]::Root,$CertificateStoreOwner)

        $CertificateStore.Open("ReadWrite")

        $CertificateStore.Add($Certificate)

        if ($CertificateStore.Certificates.Contains($Certificate)) {
            Write-Host "Certificate added succesfully"
        }
        else {
            Write-Warning "Adding certificate failed"
        }

        $CertificateStore.Close()
    }
}