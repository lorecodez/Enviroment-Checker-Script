$ServerListFilePath = "C:\Users\Lore\Desktop\scripts\enviroment-checker\enviroment-checker-list.csv"

$ServerList = Import-Csv -path $ServerListFilePath -Delimiter ','

Write-Host $ServerList

$Export = [System.Collections.ArrayList]@()
ForEach($Server in $ServerList){
    $Address = $Server.ServerAddress
    $LastStatus = $Server.LastStatus
    $Name = $Server.ServerName
    $DownSince = $Server.DownSince
    $LastDownAlertTime = $Server.LastDownAlertTime
    $LastCheckTime = $Server.LastCheckTime
    
    $Connection = Test-Connection $Address -Count 1

    $DateTime = Get-Date

    if($Connection.Status -eq 'Success'){
        
        if($LastStatus -ne 'Success'){
            $Server.DownSince = $null
            $Server.LastDonwAlertTime = $null
            Write-Output "$($Name) is now online, last checked $LastCheckTime"
        } else {
            Write-Output "$($Name) is online, last checked $LastCheckTime"
        }

    } else {

        if($LastStatus -eq 'Success'){

            Write-Output "$($Name) is now offline"
            $Server.DownSine = $DateTime
            $Server.LastDownAlertTime = $DateTime

        } else {
            $DownFor = $(((Get-Date -Date $DateTime) - (Get-Date -Date $DownSince))).TotalDays
            $SinceLastDownAlert = $(((Get-Date -Date $DateTime) - (Get-Date -Date $LastDownAlertTime))).TotalDays

            if(($DownFor -ge 1) -and ($SinceLastDownAlert -ge 1)){
                Write-Output "It has been $SinceLastDownAlert days since last alert"
                Write-Output "$($Name) is offline for $DownFor days"
                $Server.LastDownAlertTime = $DateTime
            }

            Write-Output "$($Name) is offline for $DownFor days"
        }
    }

    $Server.LastStatus = $Connection.Status
    $Server.LastCheckTime = $DateTime
    [Void]$Export.add($Server)
}

$Export | Export-Csv -Path $ServerListFilePath -Delimiter ',' -NoTypeInformation