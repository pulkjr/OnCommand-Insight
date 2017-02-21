# Function for multipart upload (based on http://blog.majcica.com/2016/01/13/powershell-tips-and-tricks-multipartform-data-requests/)
function Invoke-MultipartFormDataUpload
{
    [CmdletBinding()]
    PARAM
    (
        [string[]][parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$InFile,
        [Uri][parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Uri,
        [PSObject]$Header
    )
    BEGIN
    {
        if (-not (Test-Path $InFile))
        {
            $errorMessage = ("File {0} missing or unable to read." -f $InFile)
            $exception =  New-Object System.Exception $errorMessage
			$errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, 'MultipartFormDataUpload', ([System.Management.Automation.ErrorCategory]::InvalidArgument), $InFile
			$PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        Add-Type -AssemblyName System.Web

        $mimeType = [System.Web.MimeMapping]::GetMimeMapping($InFile)
            
        if ($mimeType)
        {
            $ContentType = $mimeType
        }
        else
        {
            $ContentType = "application/octet-stream"
        }
    }
    PROCESS
    {
        Add-Type -AssemblyName System.Net.Http

		$httpClientHandler = New-Object System.Net.Http.HttpClientHandler

        $httpClient = New-Object System.Net.Http.Httpclient $httpClientHandler

        if ($Header.Authorization) {
            $httpClient.DefaultRequestHeaders.Authorization = $Header.Authorization
        }

        # set HTTP Client Timeout to a large value - e.g. 24 hours (in microsecends) to prevent timeout during upload and following processing of data (e.g. restore)
        $httpClient.Timeout = 864000000000

        $packageFileStream = New-Object System.IO.FileStream @($InFile, [System.IO.FileMode]::Open)
        
		$contentDispositionHeaderValue = New-Object System.Net.Http.Headers.ContentDispositionHeaderValue "form-data"
	    $contentDispositionHeaderValue.Name = "backupFile"
		$contentDispositionHeaderValue.FileName = (Split-Path $InFile -leaf)

        $contentDispositionHeaderValue

        $streamContent = New-Object System.Net.Http.StreamContent $packageFileStream
        $streamContent.Headers.ContentDisposition = $contentDispositionHeaderValue
        $streamContent.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue $ContentType
        
        $content = New-Object System.Net.Http.MultipartFormDataContent
        $content.Add($streamContent)

        try
        {
            Write-Host "Starting upload"
			$response = $httpClient.PostAsync($Uri, $content).Result

			if (!$response.IsSuccessStatusCode)
			{
				$responseBody = $response.Content.ReadAsStringAsync().Result
				$errorMessage = "Status code {0}. Reason {1}. Server reported the following message: {2}." -f $response.StatusCode, $response.ReasonPhrase, $responseBody

				throw [System.Net.Http.HttpRequestException] $errorMessage
			}

			return $response.Content.ReadAsStringAsync().Result
        }
        catch [Exception]
        {
			$PSCmdlet.ThrowTerminatingError($_)
        }
        finally
        {
            if($null -ne $httpClient)
            {
                $httpClient.Dispose()
            }

            if($null -ne $response)
            {
                $response.Dispose()
            }
        }
    }
    END { }
}