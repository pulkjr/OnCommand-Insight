# Functions necessary to parse JSON output from .NET serializer to PowerShell Objects
function ParseItem($jsonItem) {
    if($jsonItem.PSObject.TypeNames -match "Array") {
        return ParseJsonArray($jsonItem)
    }
    elseif($jsonItem.PSObject.TypeNames -match "Dictionary") {
        return ParseJsonObject([HashTable]$jsonItem)
    }
    else {
        return $jsonItem
    }
}

function ParseJsonObject($jsonObj) {
    $result = New-Object -TypeName PSCustomObject
    foreach ($key in $jsonObj.Keys) {
        $item = $jsonObj[$key]
        if ($item) {
            $parsedItem = ParseItem $item
        } else {
            $parsedItem = $null
        }
        $result | Add-Member -MemberType NoteProperty -Name $key -Value $parsedItem
    }
    return $result
}

function ParseJsonArray($jsonArray) {
    $result = @()
    $jsonArray | ForEach-Object {
        $result += ,(ParseItem $_)
    }
    return $result
}

function ParseJsonString($json) {
    $config = $javaScriptSerializer.DeserializeObject($json)
    if ($config -is [Array]) {
        return ParseJsonArray($config)       
    }
    else {
        return ParseJsonObject($config)
    }
}