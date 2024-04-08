$ServerListFilePath = "C:\Users\Lore\Desktop\scripts\enviroment-checker\enviroment-checker-list.csv"

$ServerList = Import-Csv -path $ServerListFilePath -Delimiter ','

Write-Host $ServerList

$Export = [System.Collections.ArrayList]@()
ForEach($Server in $ServerList){
    $Address = $Server.ServerAddress
    $LastStatus = $Server.LastStatus
    
    $Connection = Test-Connection $Address -Count 1

    if($Connection.Status -eq 'Success'){
        Write-Output "$($Address) is online"
    } else {
        Write-Output "$($Address) is offline"
    }

    $Server.LastStatus = $Connection.Status
    [Void]$Export.add($Server)
}

$Export | Export-Csv -Path $ServerListFilePath -Delimiter ',' -NoTypeInformation