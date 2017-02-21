### Parsing Functions
function ParseExceptionBody($Response) {
    if ($Response) {
        $Reader = New-Object System.IO.StreamReader($Response.GetResponseStream())
        $Reader.BaseStream.Position = 0
        $Reader.DiscardBufferedData()
        $ResponseBody = $reader.ReadToEnd()
        if ($ResponseBody.StartsWith('{')) {
            $ResponseBody = $ResponseBody | ConvertFrom-Json | ConvertTo-Json
        }
        return $ResponseBody
    }
    else {
        return $Response
    }
}

function ParseAcquisitionUnits($AcquisitionUnits) {
    $AcquisitionUnits = @($AcquisitionUnits)
    foreach ($AcquisitionUnit in $AcquisitionUnits) {
        if ($AcquisitionUnit.nextLeaseRenewal) {
            $AcquisitionUnit.nextLeaseRenewal = $AcquisitionUnit.nextLeaseRenewal | Get-Date
        }

        if ($AcquisitionUnit.lastReported) {
            $AcquisitionUnit.lastReported = $AcquisitionUnit.lastReported | Get-Date
        }

        if ($AcquisitionUnit.datasources) {
            $AcquisitionUnit.datasources = ParseDatasources($AcquisitionUnit.datasources)
        } 

        Write-Output $AcquisitionUnit
    }
}

function ParseActivePatches($ActivePatches) {
    $ActivePatches = @($ActivePatches)
    foreach ($ActivePatch in $ActivePatches) {
        if ($ActivePatch.createTime) {
            $ActivePatch.createTime = $ActivePatch.createTime | Get-Date
        }
        if ($ActivePatch.lastUpdateTime) {
            $ActivePatch.lastUpdateTime = $ActivePatch.lastUpdateTime | Get-Date
        }

        Write-Output $ActivePatch
    }
}

function ParseDatasources($Datasources) {
    $Datasources = @($Datasources)
    foreach ($Datasource in $Datasources) {
        if ($Datasource.lastSuccessfullyAcquired) {
            $Datasource.lastSuccessfullyAcquired = $Datasource.lastSuccessfullyAcquired | Get-Date
        }

        if ($Datasource.resumeTime) {
            $Datasource.resumeTime = $Datasource.resumeTime | Get-Date
        }
        if ($Datasource.AcquisitionUnit) {
            $Datasource.AcquisitionUnit = ParseAcquisitionUnits($Datasource.AcquisitionUnit)
        }
        if ($Datasource.Changes) {
            $Datasource.Changes = ParseChanges($Datasource.Changes)
        }
        if ($Datasource.Events) {
            $Datasource.Events = ParseEvents($Datasource.Events)
        }
        if ($Datasource.activePatch) {
            $Datasource.activePatch = ParseActivePatches($Datasource.activePatch)
        }
        if ($Datasource.config) {
            $Datasource.config = ParseDatasourceConfig($Datasource.config)
        }
        Write-Output $Datasource
    }
}

function ParseDatasourceTypes($DatasourceTypes) {
    $DatasourceTypes = @($DatasourceTypes)
    foreach ($DatasourceType in $DatasourceTypes) {
        Write-Output $DatasourceType
    }
}

function ParseDatasourceConfig($DatasourceConfig) {
    $DatasourceConfig = @($DatasourceConfig)
    foreach ($DatasourceConfig in $DatasourceConfig) {
        if ($DatasourceConfig.packages | ? { $_.id -eq "foundation" }) {
            $DatasourceConfig | Add-Member -MemberType ScriptProperty -Name "foundation" -Value { $this.packages | ? { $_.id -eq "foundation" } }
            if (!$DatasourceConfig.foundation.attributes.password) {
                $DatasourceConfig.foundation.attributes | Add-Member -MemberType NoteProperty -Name password -Value "" -force
            }
            if ($DatasourceConfig.foundation.attributes.'partner.ip' -and !$DatasourceConfig.foundation.attributes.'partner.password') {
                $DatasourceConfig.foundation.attributes | Add-Member -MemberType NoteProperty -Name 'partner.password' -Value "" -force
            }
        }
        if ($DatasourceConfig.packages | ? { $_.id -eq "storageperformance" }) {
            $DatasourceConfig | Add-Member -MemberType ScriptProperty -Name "storageperformance" -Value { $this.packages | ? { $_.id -eq "storageperformance" } }
        }
        if ($DatasourceConfig.packages | ? { $_.id -eq "hostvirtualization" }) {
            $DatasourceConfig | Add-Member -MemberType ScriptProperty -Name "hostvirtualization" -Value { $this.packages | ? { $_.id -eq "hostvirtualization" } }
        }
        if ($DatasourceConfig.packages | ? { $_.id -eq "performance" }) {
            $DatasourceConfig | Add-Member -MemberType ScriptProperty -Name "performance" -Value { $this.packages | ? { $_.id -eq "performance" } }
        }
        if ($DatasourceConfig.packages | ? { $_.id -eq "cloud" }) {
            $DatasourceConfig | Add-Member -MemberType ScriptProperty -Name "cloud" -Value { $this.packages | ? { $_.id -eq "cloud" } }
        }
        Write-Output $DatasourceConfig
    }
}

function ParseChanges($Changes) {
    $Changes = @($Changes)
    foreach ($Change in $Changes) {
        if ($Change.time) {
            $Change.time = $Change.time | Get-Date
        }

        Write-Output $Change
    }
}

function ParseEvents($Events) {
    $Events = @($Events)
    foreach ($Event in $Events) {
        if ($Event.StartTime) {
            $Event.StartTime = $Event.StartTime | Get-Date
        }
        if ($Event.EndTime) {
            $Event.EndTime = $Event.EndTime | Get-Date
        }

        Write-Output $Event
    }
}

function ParseCertificates($Certificates) {
    $Certificates = @($Certificates)
    foreach ($Certificate in $Certificates) {
        if ($Certificate.ExpirationDate) {
            $Certificate.ExpirationDate = $Certificate.ExpirationDate | Get-Date
        }

        Write-Output $Certificate
    }
}

function ParseLicenseStatus($LicenseStatus) {
    $LicenseStatus.LicenseParts = ParseLicenses($LicenseStatus.LicenseParts)

    Write-Output $LicenseStatus
}

function ParseLicenses($Licenses) {
    $Licenses = @($Licenses)
    foreach ($License in $Licenses) {
        if ($License.ExpirationDate) {
            $License.ExpirationDate = $License.ExpirationDate | Get-Date
        }

        Write-Output $License
    }
}

function ParseUsers($Users) {
    $Users = @($Users)
    foreach ($User in $Users) {
        if ($User.lastLogin) {
            $User.lastLogin = $User.lastLogin | Get-Date
        }

        Write-Output $User
    }
}

function ParseDatastores($Datastores) {
    $Datastores = @($Datastores)
    foreach ($Datastore in $Datastores) {
        if ($Datastore.performance) {
            $Datastore.performance = ParsePerformance($Datastore.performance)
        }

        Write-Output $Datastore
    }
}

function ParseSwitches($Switches) {
    $Switches = @($Switches)
    foreach ($Switch in $Switches) {
        if ($Switch.createTime) {
            $Switch.createTime = $Switch.createTime | Get-Date
        }
        if ($Switch.performance) {
            $Switch.performance = ParsePerformance($Switch.performance)
        }
        if ($Switch.fabric) {
            $Switch.fabric = ParseFabrics($Switch.fabric)
        }
        if ($Switch.ports) {
            $Switch.ports = ParsePorts($Switch.ports)
        }
        if ($Switch.annotations) {
            $Switch.annotations = ParseAnnotations($Switch.annotations)
        }
        if ($Switch.datasources) {
            $Switch.datasources = ParseDatasources($Switch.datasources)
        }
        if ($Switch.applications) {
            $Switch.applications = ParseApplications($Switch.applications)
        }

        Write-Output $Switch
    }
}

function ParsePerformance($Performance) {
    if ($Performance.accessed) {
        $Performance.accessed.start = $Performance.accessed.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.accessed.end = $Performance.accessed.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
    }
    if ($Performance.cacheHitRatio) {
        if ($Performance.cacheHitRatio.read) {
            $Performance.cacheHitRatio.read.start = $Performance.cacheHitRatio.read.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
            $Performance.cacheHitRatio.read.end = $Performance.cacheHitRatio.read.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        }
        if ($Performance.cacheHitRatio.write) {
            $Performance.cacheHitRatio.write.start = $Performance.cacheHitRatio.write.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
            $Performance.cacheHitRatio.write.end = $Performance.cacheHitRatio.write.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        }
        if ($Performance.cacheHitRatio.total) {
            $Performance.cacheHitRatio.total.start = $Performance.cacheHitRatio.total.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
            $Performance.cacheHitRatio.total.end = $Performance.cacheHitRatio.total.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        }
    }
    if ($Performance.cpuUtilization) {
        $Performance.cpuUtilization.total.start = $Performance.cpuUtilization.total.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.cpuUtilization.total.end = $Performance.cpuUtilization.total.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
    }
    if ($Performance.diskIops) {
        $Performance.diskIops.read.start = $Performance.diskIops.read.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskIops.read.end = $Performance.diskIops.read.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskIops.write.start = $Performance.diskIops.write.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskIops.write.end = $Performance.diskIops.write.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskIops.totalMax.start = $Performance.diskIops.totalMax.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskIops.totalMax.end = $Performance.diskIops.totalMax.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskIops.total.start = $Performance.diskIops.total.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskIops.total.end = $Performance.diskIops.total.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
    }
    if ($Performance.diskLatency) {
        $Performance.diskLatency.read.start = $Performance.diskLatency.read.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskLatency.read.end = $Performance.diskLatency.read.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskLatency.write.start = $Performance.diskLatency.write.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskLatency.write.end = $Performance.diskLatency.write.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskLatency.total.start = $Performance.diskLatency.total.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskLatency.total.end = $Performance.diskLatency.total.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskLatency.totalMax.start = $Performance.diskLatency.totalMax.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskLatency.totalMax.end = $Performance.diskLatency.totalMax.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
    }
    if ($Performance.diskThroughput) {
        $Performance.diskThroughput.read.start = $Performance.diskThroughput.read.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskThroughput.read.end = $Performance.diskThroughput.read.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskThroughput.write.start = $Performance.diskThroughput.write.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskThroughput.write.end = $Performance.diskThroughput.write.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskThroughput.totalMax.start = $Performance.diskThroughput.totalMax.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskThroughput.totalMax.end = $Performance.diskThroughput.totalMax.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskThroughput.total.start = $Performance.diskThroughput.total.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.diskThroughput.total.end = $Performance.diskThroughput.total.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
    }
    if ($Performance.fcWeightedPortBalanceIndex) {
        $Performance.fcWeightedPortBalanceIndex.start = $Performance.fcWeightedPortBalanceIndex.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.fcWeightedPortBalanceIndex.end = $Performance.fcWeightedPortBalanceIndex.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
    }
    if ($Performance.iops) {
        $Performance.iops.read.start = $Performance.iops.read.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.iops.read.end = $Performance.iops.read.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.iops.write.start = $Performance.iops.write.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.iops.write.end = $Performance.iops.write.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.iops.totalMax.start = $Performance.iops.totalMax.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.iops.totalMax.end = $Performance.iops.totalMax.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.iops.total.start = $Performance.iops.total.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.iops.total.end = $Performance.iops.total.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
    }
    if ($Performance.ipThroughput) {
        $Performance.ipThroughput.read.start = $Performance.ipThroughput.read.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.ipThroughput.read.end = $Performance.ipThroughput.read.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.ipThroughput.write.start = $Performance.ipThroughput.write.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.ipThroughput.write.end = $Performance.ipThroughput.write.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.ipThroughput.totalMax.start = $Performance.ipThroughput.totalMax.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.ipThroughput.totalMax.end = $Performance.ipThroughput.totalMax.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.ipThroughput.total.start = $Performance.ipThroughput.total.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.ipThroughput.total.end = $Performance.ipThroughput.total.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
    }
    if ($Performance.latency) {
        $Performance.latency.read.start = $Performance.latency.read.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.latency.read.end = $Performance.latency.read.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.latency.write.start = $Performance.latency.write.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.latency.write.end = $Performance.latency.write.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.latency.total.start = $Performance.latency.total.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.latency.total.end = $Performance.latency.total.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.latency.totalMax.start = $Performance.latency.totalMax.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.latency.totalMax.end = $Performance.latency.totalMax.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
    }
    if ($Performance.memoryUtilization) {
        $Performance.memoryUtilization.total.start = $Performance.memoryUtilization.total.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.memoryUtilization.total.end = $Performance.memoryUtilization.total.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
    }
    if ($Performance.partialBlocksRatio.total) {
        $Performance.partialBlocksRatio.total.start = $Performance.partialBlocksRatio.total.start | ? { $_ } | ConvertFrom-UnixTimestamp
        $Performance.partialBlocksRatio.total.end = $Performance.partialBlocksRatio.total.end | ? { $_ } | ConvertFrom-UnixTimestamp
    }
    if ($Performance.swapRate) {
        $Performance.swapRate.inRate.start = $Performance.swapRate.inRate.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.swapRate.inRate.end = $Performance.swapRate.inRate.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.swapRate.outRate.start = $Performance.swapRate.outRate.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.swapRate.outRate.end = $Performance.swapRate.outRate.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.swapRate.totalMaxRate.start = $Performance.swapRate.totalMaxRate.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.swapRate.totalMaxRate.end = $Performance.swapRate.totalMaxRate.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.swapRate.totalRate.start = $Performance.swapRate.totalRate.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.swapRate.totalRate.end = $Performance.swapRate.totalRate.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
    }
    if ($Performance.throughput) {
        $Performance.throughput.read.start = $Performance.throughput.read.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.throughput.read.end = $Performance.throughput.read.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.throughput.write.start = $Performance.throughput.write.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.throughput.write.end = $Performance.throughput.write.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.throughput.totalMax.start = $Performance.throughput.totalMax.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.throughput.totalMax.end = $Performance.throughput.totalMax.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.throughput.total.start = $Performance.throughput.total.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.throughput.total.end = $Performance.throughput.total.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
    }
    if ($Performance.writePending.total) {
        $Performance.writePending.total.start = $Performance.writePending.total.start | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
        $Performance.writePending.total.end = $Performance.writePending.total.end | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone
    }
    if ($Performance.history) {
        $Performance.history = ParsePerformanceHistory($Performance.history)
    }

    Write-Output $Performance
}

function ParsePerformanceHistory($PerformanceHistory) {
    if ($PerformanceHistory[0].count -eq 2) {
        $PerformanceHistory = foreach ($entry in $PerformanceHistory) {
            if ($entry[1] -replace ' ','') {
                $entry[1] | Add-Member -MemberType NoteProperty -Name timestamp -Value ($entry[0] | ? { $_ } | ConvertFrom-UnixTimestamp -Timezone $Server.Timezone) -PassThru
            }
        }
    }
    Write-Output $PerformanceHistory
} 

function ParseVirtualMachines($VirtualMachines) {
    $VirtualMachines = @($VirtualMachines)
    foreach ($VirtualMachine in $VirtualMachines) {
        if ($VirtualMachine.createTime) {
            $VirtualMachine.createTime = $VirtualMachine.createTime | Get-Date
        }
        if ($VirtualMachine.performance) {
            $VirtualMachine.performance = ParsePerformance($VirtualMachine.performance)
        }
        if ($VirtualMachine.vmdks) {
            $VirtualMachine.vmdks = ParseVmdks($VirtualMachine.vmdks)
        }
        if ($VirtualMachine.host) {
            $VirtualMachine.host = ParseHosts($VirtualMachine.host)
        }
        if ($VirtualMachine.ports) {
            $VirtualMachine.ports = ParsePorts($VirtualMachine.ports)
        }
        if ($VirtualMachine.dataStore) {
            $VirtualMachine.dataStore = ParseDatastores($VirtualMachine.dataStore)
        }
        if ($VirtualMachine.applications) {
            $VirtualMachine.applications = ParseApplications($VirtualMachine.applications)
        }
        if ($VirtualMachine.fileSystems) {
            $VirtualMachine.fileSystems = ParseFileSystems($VirtualMachine.fileSystems)
        }
        if ($VirtualMachine.storageResources) {
            $VirtualMachine.storageResources = ParseStorageResources($VirtualMachine.storageResources)
        }
        if ($VirtualMachine.annotations) {
            $VirtualMachine.annotations = ParseAnnotations($VirtualMachine.annotations)
        }
        if ($VirtualMachine.datasources) {
            $VirtualMachine.datasources = ParseDatasources($VirtualMachine.datasources)
        }

        Write-Output $VirtualMachine
    }
}

function ParseVmdks($Vmdks) {
    $Vmdks = @($Vmdks)
    foreach ($Vmdk in $Vmdks) {
        if ($vmdk.dataStore) {
            $vmdk.dataStore = ParseDatastores($vmdk.dataStore)
        }
        if ($vmdk.virtualMachine) {
            $vmdk.virtualMachine = ParseVirtualMachines($vmdk.virtualMachine)
        }
        if ($vmdk.performance) {
            $vmdk.performance = ParsePerformance($vmdk.performance)
        }
        if ($vmdk.storageResources) {
            $vmdk.storageResources = ParseStorageResources($vmdk.storageResources)
        }
        if ($vmdk.annotations) {
            $vmdk.annotations = ParseAnnotations($vmdk.annotations)
        }
        if ($vmdk.datasources) {
            $vmdk.datasources = ParseDatasources($vmdk.datasources)
        }

        Write-Output $vmdk
    }
}

function ParseHosts($Hosts) {
    foreach ($HostInstance in $Hosts) {
        if ($HostInstance.createTime) {
            $HostInstance.createTime = $HostInstance.createTime | Get-Date
        }
        if ($HostInstance.performance) {
            $HostInstance.performance = ParsePerformance($HostInstance.performance)
        }
        if ($HostInstance.storageResources) {
            $HostInstance.storageResources = ParseStorageResources($HostInstance.storageResources)
        }
        if ($HostInstance.fileSystems) {
            $HostInstance.fileSystems = ParseFileSystems($HostInstance.fileSystems)
        }
        if ($HostInstance.ports) {
            $HostInstance.ports = ParsePorts($HostInstance.ports)
        }
        if ($HostInstance.applications) {
            $HostInstance.applications = ParseApplications($HostInstance.applications)
        }
        if ($HostInstance.virtualMachines) {
            $HostInstance.virtualMachines = ParseVirtualMachines($HostInstance.virtualMachines)
        }
        if ($HostInstance.clusterHosts) {
            $HostInstance.clusterHosts = ParseHosts($HostInstance.clusterHosts)
        }
        if ($HostInstance.annotations) {
            $HostInstance.annotations = ParseAnnotations($HostInstance.annotations)
        }
        if ($HostInstance.datasources) {
            $HostInstance.datasources = ParseDatasources($HostInstance.datasources)
        }

        Write-Output $HostInstance
    }
}

function ParseTopologies($Topologies) {
    foreach ($Topology in $Topologies) {
        if ($Topology.nodes) {
            $Topology.nodes = ParseTopologyNodes($Topology.nodes)
        }
        if ($Topology.links) {
            $Topology.links = ParseTopologyLinks($Topology.links)
        }

        Write-Output $Topology
    }
}

function ParseTopologyNodes($Nodes) {
    foreach ($Node in $Nodes) {
        Write-Output $Node
    }
}

function ParseTopologyLinks($Links) {
    foreach ($Link in $Links) {
        Write-Output $Link
    }
}


function ParsePorts($Ports) {
    $Ports = @($Ports)
    foreach ($Port in $Ports) {
        if ($Port.connectedPorts) {
            $Port.connectedPorts = ParsePorts($Port.connectedPorts)
        }
        if ($Port.performance) {
            $Port.performance = ParsePerformance($Port.performance)
        }
        if ($Port.device) {
            $Port.device = ParseDevices($Port.device)
        }
        if ($Port.fabrics) {
            $Port.fabrics = ParseFabrics($Port.fabrics)
        }
        if ($Port.annotations) {
            $Port.annotations = ParseAnnotations($Port.annotations)
        }
        if ($Port.datasources) {
            $Port.datasources = ParseDatasources($Port.datasources)
        }
        if ($Port.application) {
            $Port.application = ParseApplication($Port.application)
        }

        Write-Output $Port
    }
}

function ParseDevices($Device) {
    $Devices = @($Devices)
    foreach ($Device in $Devices) {
        if ($Device.performance) {
            $Device.performance = ParsePerformance($Device.performance)
        }
        if ($Device.device) {
            $Device.device = ParseDevice($Device.device)
        }
        if ($Device.fabrics) {
            $Device.fabrics = ParseFabrics($Device.fabrics)
        }
        if ($Device.annotations) {
            $Device.annotations = ParseAnnotations($Device.annotations)
        }
        if ($Device.datasources) {
            $Device.datasources = ParseDatasources($Device.datasources)
        }
        if ($Device.application) {
            $Device.application = ParseApplication($Device.application)
        }

        Write-Output $Device
    }
}

function ParseApplications($Applications) {
    $Applications = @($Applications)
    foreach ($Application in $Applications) {
        if (!$Application.isBusinessEntityDefault) {
            Write-Output $Application
        }
    }
}

function ParseAnnotations($Annotations) {
    $Annotations = @($Annotations)
    foreach ($Annotation in $Annotations) {

        Write-Output $Annotation
    }
}

function ParseComputeResources($ComputeResources) {
    $ComputeResources = @($ComputeResources)
    foreach ($ComputeResource in $ComputeResources) {
        if ($ComputeResource.createTime) {
            $ComputeResource.createTime = $ComputeResource.createTime | Get-Date
        }
        if ($ComputeResource.performance) {
            $ComputeResource.performance = ParsePerformance($ComputeResource.performance)
        }
        if ($ComputeResource.storageResources) {
            $ComputeResource.storageResources = ParseStorageResources($ComputeResource.storageResources)
        }
        if ($ComputeResource.fileSystems) {
            $ComputeResource.fileSystems = ParseFileSystems($ComputeResource.fileSystems)
        }
        if ($ComputeResource.ports) {
            $ComputeResource.ports = ParsePorts($ComputeResource.ports)
        }
        if ($ComputeResource.applications) {
            $ComputeResource.applications = ParseApplications($ComputeResource.applications)
        }
        if ($ComputeResource.virtualMachines) {
            $ComputeResource.virtualMachines = ParseVirtualMachines($ComputeResource.virtualMachines)
        }
        if ($ComputeResource.clusterHosts) {
            $ComputeResource.clusterHosts = ParseHosts($ComputeResource.clusterHosts)
        }
        if ($ComputeResource.annotations) {
            $ComputeResource.annotations = ParseAnnotations($ComputeResource.annotations)
        }
        if ($ComputeResource.datasources) {
            $ComputeResource.datasources = ParseDatasources($ComputeResource.datasources)
        }

        Write-Output $ComputeResource
    }
}

function ParseStorageResources($StorageResources) {
    $StorageResources = @($StorageResources)
    foreach ($StorageResource in $StorageResources) {
        if ($StorageResource.createTime) {
            $StorageResource.createTime = $StorageResource.createTime | Get-Date
        }
        if ($StorageResource.performance) {
            $StorageResource.performance = ParsePerformance($StorageResource.performance)
        }
        if ($StorageResource.computeResources) {
            $StorageResource.computeResources = ParseComputeResources($StorageResource.computeResources)
        }
        if ($StorageResource.fileSystems) {
            $StorageResource.fileSystems = ParseFileSystems($StorageResource.fileSystems)
        }
        if ($StorageResource.storagePools) {
            $StorageResource.storagePools = ParseStoragePools($StorageResource.storagePools)
        }
        if ($StorageResource.applications) {
            $StorageResource.applications = ParseApplications($StorageResource.applications)
        }
        if ($StorageResource.virtualMachines) {
            $StorageResource.virtualMachines = ParseVirtualMachines($StorageResource.virtualMachines)
        }
        if ($StorageResource.annotations) {
            $StorageResource.annotations = ParseAnnotations($StorageResource.annotations)
        }
        if ($StorageResource.datasources) {
            $StorageResource.datasources = ParseDatasources($StorageResource.datasources)
        }

        Write-Output $StorageResource
    }
}

function ParseVolumes($Volumes) {
    $Volumes = @($Volumes)
    foreach ($Volume in $Volumes) {
        if ($Volume.storage) {
            $Volume.storage = ParseStorages($Volume.storage)
        }
        if ($Volume.computeResources) {
            $Volume.computeResources = ParseComputeResources($Volume.computeResources)
        }
        if ($Volume.storagePool) {
            $Volume.storagePool = ParseStoragePools($Volume.storagePool)
        }
        if ($Volume.virtualStoragePool) {
            $Volume.virtualStoragePool = ParseStoragePools($Volume.virtualStoragePool)
        }
        if ($Volume.qtrees) {
            $Volume.qtrees = ParseAnnotations($Volume.qtrees)
        }
        if ($Volume.internalVolume) {
            $Volume.internalVolume = ParseInternalVolumes($Volume.internalVolume)
        }
        if ($Volume.dataStores) {
            $Volume.dataStores = ParseDatastores($Volume.dataStores)
        }
        if ($Volume.annotations) {
            $Volume.annotations = ParseAnnotations($Volume.annotations)
        }
        if ($Volume.performance) {
            $Volume.performance = ParsePerformance($Volume.performance)
        }
        if ($Volume.ports) {
            $Volume.ports = ParsePorts($Volume.ports)
        }
        if ($Volume.storageNodes) {
            $Volume.storageNodes = ParseStorageNodes($Volume.storageNodes)
        }
        if ($Volume.replicaSources) {
            $Volume.replicaSources = ParseVolumes($Volume.replicaSources)
        }
        if ($Volume.applications) {
            $Volume.applications = ParseApplications($Volume.applications)
        }
        if ($Volume.datasources) {
            $Volume.datasources = ParseDatasources($Volume.datasources)
        }

        Write-Output $Volume
    }
}

function ParseInternalVolumes($InternalVolumes) {
    $InternalVolumes = @($InternalVolumes)
    foreach ($InternalVolume in $InternalVolumes) {
        if ($InternalVolume.storage) {
            $InternalVolume.storage = ParseStorages($InternalVolume.storage)
        }
        if ($InternalVolume.computeResources) {
            $InternalVolume.computeResources = ParseComputeResources($InternalVolume.computeResources)
        }
        if ($InternalVolume.storagePool) {
            $InternalVolume.storagePool = ParseStoragePools($InternalVolume.storagePool)
        }
        if ($InternalVolume.performance) {
            $InternalVolume.performance = ParsePerformance($InternalVolume.performance)
        }
        if ($InternalVolume.volumes) {
            $InternalVolume.volumes = ParseVolumes($InternalVolume.volumes)
        }
        if ($InternalVolume.storageNodes) {
            $InternalVolume.storageNodes = ParseStorageNodes($InternalVolume.storageNodes)
        }
        if ($InternalVolume.datasources) {
            $InternalVolume.datasources = ParseDatasources($InternalVolume.datasources)
        }
        if ($InternalVolume.datastores) {
            $InternalVolume.datastores = ParseDatastores($InternalVolume.datastores)
        }
        if ($InternalVolume.applications) {
            $InternalVolume.applications = ParseApplications($InternalVolume.applications)
        }
        if ($InternalVolume.annotations) {
            $InternalVolume.annotations = ParseAnnotations($InternalVolume.annotations)
        }
        if ($InternalVolume.qtrees) {
            $InternalVolume.qtrees = ParseAnnotations($InternalVolume.qtrees)
        }

        Write-Output $InternalVolume
    }
}

function ParseQtrees($Qtrees) {
    $Qtrees = @($Qtrees)
    foreach ($Qtree in $Qtrees) {
        if ($Qtree.quotaCapacity) {
            $Qtree.quotaCapacity = ParseQuotaCapacities($Qtree.quotaCapacity)
        }
        if ($Qtree.storage) {
            $Qtree.storage = ParseStorages($Qtree.storage)
        }
        if ($Qtree.internalVolume) {
            $Qtree.internalVolume = ParseInternalVolumes($Qtree.internalVolume)
        }
        if ($Qtree.shares) {
            $Qtree.shares = ParseShares($Qtree.shares)
        }
        if ($Qtree.annotations) {
            $Qtree.annotations = ParseAnnotations($Qtree.annotations)
        }
        if ($Qtree.applications) {
            $Qtree.applications = ParseApplications($Qtree.applications)
        }
        if ($Qtree.volumes) {
            $Qtree.volumes = ParseVolumes($Qtree.volumes)
        }

        Write-Output $Qtree
    }
}

function ParseQuotaCapacities($QuotaCapacities) {
    $QuotaCapacities = @($QuotaCapacities)
    foreach ($QuotaCapacity in $QuotaCapacities) {
        Write-Output $QuotaCapacity
    }
}

function ParseShares($Qtrees) {
    $Shares = @($Shares)
    foreach ($Share in $Shares) {
        Write-Output $Share
    }
}

function ParseStoragePools($StoragePools) {
    $StoragePools = @($StoragePools)
    foreach ($StoragePool in $StoragePools) {
        if ($StoragePool.performance) {
            $StoragePool.performance = ParsePerformance($StoragePool.performance)
        }
        if ($StoragePool.storage) {
            $StoragePool.storage = ParseStorages($StoragePool.storage)
        }
        if ($StoragePool.disks) {
            $StoragePool.disks = ParseDisks($StoragePool.disks)
        }
        if ($StoragePool.storageResources) {
            $StoragePool.storageResources = ParseStorageResources($StoragePool.storageResources)
        }
        if ($StoragePool.internalVolumes) {
            $StoragePool.internalVolumes = ParseInternalVolumes($StoragePool.internalVolumes)
        }
        if ($StoragePool.volumes) {
            $StoragePool.volumes = ParseVolumes($StoragePool.volumes)
        }
        if ($StoragePool.storageNodes) {
            $StoragePool.storageNodes = ParseStorageNodes($StoragePool.storageNodes)
        }
        if ($StoragePool.datasources) {
            $StoragePool.datasources = ParseDatasources($StoragePool.datasources)
        }
        if ($StoragePool.annotations) {
            $StoragePool.annotations = ParseAnnotations($StoragePool.annotations)
        }

        Write-Output $StoragePool
    }
}

function ParseStorages($Storages) {
    $Storages = @($Storages)
    foreach ($Storage in $Storages) {
        if ($Storage.createTime) {
            $Storage.createTime = $Storage.createTime | Get-Date
        }
        if ($Storage.storageNodes) {
            $Storage.storageNodes = ParseStorageNodes($Storage.storageNodes)
        }
        if ($Storage.storagePools) {
            $Storage.storagePools = ParseStoragePools($Storage.storagePools)
        }
        if ($Storage.storageResources) {
            $Storage.storageResources = ParseStorageResources($Storage.storageResources)
        }
        if ($Storage.internalVolumes) {
            $Storage.internalVolumes = ParseInternalVolumes($Storage.internalVolumes)
        }
        if ($Storage.volumes) {
            $Storage.volumes = ParseVolumes($Storage.volumes)
        }
        if ($Storage.disks) {
            $Storage.disks = ParseDisks($Storage.disks)
        }
        if ($Storage.datasources) {
            $Storage.datasources = ParseDatasources($Storage.datasources)
        }
        if ($Storage.ports) {
            $Storage.ports = ParsePorts($Storage.ports)
        }
        if ($Storage.annotations) {
            $Storage.annotations = ParseAnnotations($Storage.annotations)
        }
        if ($Storage.qtrees) {
            $Storage.qtrees = ParseQtrees($Storage.qtrees)
        }
        if ($Storage.shares) {
            $Storage.shares = ParseShares($Storage.shares)
        }
        if ($Storage.applications) {
            $Storage.applications = ParseApplications($Storage.applications)
        }
        if ($Storage.performance) {
            $Storage.performance = ParsePerformance($Storage.performance)
        }

        Write-Output $Storage
    }
}

function ParseStorageNodes($StorageNodes) {
    $StorageNodes = @($StorageNodes)
    foreach ($StorageNode in $StorageNodes) {
        if ($StorageNode.performance) {
            $StorageNode.performance = ParsePerformance($StorageNode.performance)
        }

        Write-Output $StorageNode
    }
}

function ParseDisks($Disks) {
    $Disks = @($Disks)
    foreach ($Disk in $Disks) {
        if ($Disk.performance) {
            $Disk.performance = ParsePerformance($Disk.performance)
        }
        if ($Disk.storage) {
            $Disk.storage = ParseStorages($Disk.storage)
        }
        if ($Disk.storageResources) {
            $Disk.storageResources = ParseStorageResources($Disk.storageResources)
        }
        if ($Disk.backendVolumes) {
            $Disk.backendVolumes = ParseVolumes($Disk.backendVolumes)
        }
        if ($Disk.datasources) {
            $Disk.datasources = ParseDatasources($Disk.datasources)
        }
        if ($Disk.annotations) {
            $Disk.annotations = ParseAnnotations($Disk.annotations)
        }

        Write-Output $Disk
    }
}

function ParseFabrics($Fabrics) {
    $Fabrics = @($Fabrics)
    foreach ($Fabric in $Fabrics) {
        if ($Fabric.datasources) {
            $Fabric.datasources = ParseDatasources($Fabric.datasources)
        }
        if ($Fabric.switches) {
            $Fabric.switches = ParseDatasources($Fabric.switches)
        }

        Write-Output $Fabric
    }
}