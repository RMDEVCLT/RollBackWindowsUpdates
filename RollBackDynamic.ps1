
Function Get-2ndTuesdayOfMonth { 
    Param (
        [Parameter(Mandatory = $true)][ValidateSet("First", "Second", "Third", "Fourth", "Last", "1", "2", "3", "4", "5")][string]$Find,
        [Parameter(Mandatory = $true)][ValidateSet("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")][string]$Weekday,
        [Parameter(Mandatory = $true)][ValidateRange(1, 12)][int]$Month,
        [Parameter(Mandatory = $true)][ValidatePattern('^\d{4}$')][int]$Year
    )
    switch ($Find) {
        "First" { $intFind = 1 }
        "Second" { $intFind = 2 }
        "Third" { $intFind = 3 }
        "Fourth" { $intFind = 4 }
        "Last" { $intFind = 5 }
        default { $intFind = [int]$Find }
    }
    $allDays = @()
    0..31 | ForEach-Object -Process {
        $evaldate = (Get-Date -Year $Year -Month $Month -Day 1).AddDays($_)
        if ($evaldate.Month -eq $Month) {        
            if ($evaldate.DayOfWeek -eq $Weekday) {
                $alldays += $evaldate
            }
        }
    }
    if ($allDays.Count -lt $intFind)
    { $intFind = $intFind - 1 }
    $allDays[$($intFind - 1)]
    Return
}
function Get-TotalDaysCount {
    $lastTuesdayLastYear = Get-2ndTuesdayOfMonth -Find Second -Weekday Tuesday -Month ($this_month - 01) -Year ((Get-Date $todaysDate -f "yyyy" ) - 1)

    if ($todaysDate -ge $thisTuesday) {
        write-host "The date is greater than this month's tuesday" -ForegroundColor Green
        $totalDaysCount = ((New-TimeSpan -start $thisTuesday -end $todaysDate).Days) + 1
        Write-Host "Days to Rollback : " $totalDaysCount -ForegroundColor Green
        return $totalDaysCount
    }
    elseif (($todaysDate -lt $thisTuesday) -and ($this_month -match 01 )) {
        write-host "The date is less than this month's tuesday" -ForegroundColor Green
        $totalDaysCount = ((New-TimeSpan -start $lastTuesdayLastYear -end $todaysDate).Days) + 1
        Write-Host "Days to Rollback : " $totalDaysCount  -ForegroundColor Green
        return $totalDaysCount
    }
    elseif ($todaysDate -lt $thisTuesday) {
        write-host "The date is less than this month's tuesday" -ForegroundColor Red
        $totalDaysCount = ((New-TimeSpan -start $lastTuesday -end $todaysDate).Days) + 1
        Write-Host "Days to Rollback : " $totalDaysCount -ForegroundColor Red
        return $totalDaysCount
    }
    else {
        Write-Host "Get-TotalDaysCount Error"
    }
}
function Get-lastFileExecutionTimeStamp {
    $totalDays = Get-TotalDaysCount
    $rollbackTimespan = New-TimeSpan -Start $thisMonthTimestamp -End $todaysDate
    if ($rollbackTimespan.days -lt $totalDays) {
        Write-host "you will accidentally roll back another month .... wait another month " -ForegroundColor Yellow
        return $false
    }
    elseif ($rollbackTimespan -gt $totalDays) {
        return $true
    }
    else {
        "Get-lastFileExecutioTimeStamp Error"
    }
}
function Get-RollbackWindowsUpdate {
    "--------------------------------------------------------"
    Remove-Item -Path "$path\UninstallJob.ps1" -erroraction silentlycontinue
    function foldercheck {
        Write-Host "Checking Staging folder existance"
        if (Test-Path -Path "$path") {
            "--------------------------------------------------------"
            "Path exists!"
        }
        else {
            "--------------------------------------------------------"
            write-host "Path doesn't exist. Check for the script rollBackDays2.ps1"
        }
    }
    foldercheck
    "--------------------------------------------------------"
 
    $SearchUpdates = dism /online /get-packages /format:table | findstr "Package_for"

    $updates = $SearchUpdates.replace("Package Identity : ", "")

    write-host "Building Code Execution..." -ForegroundColor Red
    "--------------------------------------------------------"
    $DaysCounted = (Get-TotalDaysCount).toString()
    $cleanup = $updates | ConvertFrom-Csv -Delimiter '|' -Header 'PackageIdentity', 'State', 'ReleaseType', 'InstallTime' `
    | Select-Object "PackageIdentity", @{n = "Time"; e = { [datetime]$_.InstallTime } } `
    | Where-Object { $_.Time -gt [datetime]::now.adddays( -$DaysCounted) } `
    | foreach-object { [string]::Concat("dism /Online /Remove-Package /PackageName:" + $_.PackageIdentity) + "/NoRestart" }
    
    write-host "CodeBuild completed..." -ForegroundColor Red
    "--------------------------------------------------------"

    write-host "Here's the Code that will be executed" -ForegroundColor Green
    "--------------------------------------------------------"
    $cleanup
    $cleanup > $path\UninstallJob.ps1


    "`n"
    write-host "*********************************************************************************" -ForegroundColor Yellow
    write-host "*************************************CAUTION*************************************" -ForegroundColor Yellow
    write-host "*********************************************************************************" -ForegroundColor Yellow
    "`n"
    write-host "Wait 30 seconds before Starting Rollback. Press Ctrl+C to cancel command" -ForegroundColor Green
    ""
    write-host "IF YOU CHOOSE TO CANCEL THE SCRIPT .... YOU WILL NEED TO DELETE THE LOGS AND START AGAIN" -ForegroundColor Red
    "`n"
    write-host "*********************************************************************************" -ForegroundColor Yellow
    write-host "*************************************CAUTION*************************************" -ForegroundColor Yellow
    write-host "*********************************************************************************" -ForegroundColor Yellow
    "`n"

    Start-Sleep -Seconds 20

    write-host "Starting Code Execution" -ForegroundColor Yellow
    "--------------------------------------------------------"
    Invoke-Expression "$path\UninstallJob.ps1"
}

function Get-DisplayDates {
    "--------------------------------------------------------"
    write-host "This month's tuesday is : " $thisTuesday.ToShortDateString() -ForegroundColor Blue
    "--------------------------------------------------------"
    write-host "Last month's tuesday is : " $lastTuesday.ToShortDateString() -ForegroundColor Magenta
    "--------------------------------------------------------"
    write-host "Today's date is : " $todaysDate.ToShortDateString() -ForegroundColor Cyan
    "--------------------------------------------------------"
    Write-Host "Last Time Ran : " $thisMonthTimestamp -ForegroundColor Red
}
function Set-Timestamp {
    get-date -format "MM/dd/yyyy"  | Out-File -FilePath "$path\thisMonthTimestamp.log"
    Write-Host "New Timestamp: "
    get-date -format "MM/dd/yyyy"
}

$path = $MyInvocation.MyCommand.Path
if (!$path) {
    $path = $psISE.CurrentFile.Fullpath
}
if ($path) {
    $path = Split-Path $path -Parent
}
Set-Location $path
$pathTest = Test-Path -path "$path\thisMonthTimestamp.log"

Remove-Item -path "$path\rollbackLog.txt" -ErrorAction SilentlyContinue
Start-Transcript -Path "$path\rollbackLog.txt"

$todaysDate = (get-date)
$this_month = (Get-Date -f "MM")
$thisTuesday = Get-2ndTuesdayOfMonth -Find Second -Weekday Tuesday -Month $this_month -Year (Get-Date -f "yyyy" )
$lastTuesday = Get-2ndTuesdayOfMonth -Find Second -Weekday Tuesday -Month ($this_month - 01) -Year (Get-Date -f "yyyy" ) 
$thisMonthTimestamp = Get-Content -Path "$path\thisMonthTimestamp.log" -ErrorAction SilentlyContinue
if ($pathTest -eq $true ) {
    $decision = Get-lastFileExecutionTimeStamp
    if ($decision -eq $true) {
        Get-DisplayDates
        Get-RollbackWindowsUpdate
        Set-Timestamp
    }
    elseif ($decision -eq $false) {
        Write-Host "Unable to Rollback"
    }
    else {
        Write-Host "Error"
    }
}
elseif ($pathTest -eq $False) {
    Set-Timestamp
    Get-DisplayDates
    Get-RollbackWindowsUpdate
}
else {
    Write-Host "PathTest Error"
}
"`n"
Stop-Transcript
exit
