# helper function to convert datetime to unix timestamp
function ConvertTo-UnixTimestamp {
    [CmdletBinding()]
 
    PARAM (
        [parameter(Mandatory=$True,
                    Position=0,
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True,
                    HelpMessage="Date to be converted.")][DateTime[]]$Date
    )

    BEGIN {
        $epoch = Get-Date -Year 1970 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0  
    }

    PROCESS {
        $Date = @($Date)

        foreach ($Date in $Date) {
                $milliSeconds = [math]::truncate($Date.ToUniversalTime().Subtract($epoch).TotalMilliSeconds)
                Write-Output $milliSeconds
        }    
    } 
}
 
# helper function to convert unix timestamp to datetime
function ConvertFrom-UnixTimestamp {
    [CmdletBinding()]

    PARAM (
        [parameter(Mandatory=$True,
                    Position=0,
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True,
                    HelpMessage="Timestamp to be converted.")][String]$Timestamp,
        [parameter(Mandatory=$False,
                    Position=1,
                    HelpMessage="Optional Timezone to be used as basis for Timestamp. Default is system Timezone.")][System.TimeZoneInfo]$Timezone=[System.TimeZoneInfo]::Local
    )

    PROCESS {
        $Timestamp = @($Timestamp)
        foreach ($Timestamp in $Timestamp) {
            $Date = [System.TimeZoneInfo]::ConvertTime(([datetime]'1/1/1970').AddMilliseconds($Timestamp),$Timezone)
            Write-Output $Date
        }
    }
}