param(
    [Parameter(Mandatory = $true)][string]$Address,
    [ValidateRange(1, 65535)][int]$Port = 5555,
    [string]$AdbPath = 'adb'
)

$ErrorActionPreference = 'Stop'
$taskIp = [System.Net.IPAddress]::Parse($Address)
if ($taskIp.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) {
    throw 'Use the IPv4 address shown in the TV network settings.'
}
$taskSerial = '{0}:{1}' -f $taskIp, $Port
$taskRepo = Split-Path $PSScriptRoot -Parent
$taskLocal = Join-Path $taskRepo 'local'
New-Item -ItemType Directory -Path $taskLocal -Force | Out-Null

$taskConnectOutput = @(& $AdbPath connect $taskSerial 2>&1)
$taskConnectExit = $LASTEXITCODE
$taskConnectOutput | Write-Output
# Some adb versions return exit code 0 even when the remote TCP port refuses the connection.
if ($taskConnectExit -ne 0 -or ($taskConnectOutput -join "`n") -match '(?i)cannot connect|failed to connect|unable to connect') {
    throw 'ADB connection failed. Confirm the TV address and enable its network/ADB debugging port.'
}
$taskState = & $AdbPath -s $taskSerial get-state 2>&1
if ($LASTEXITCODE -ne 0 -or (($taskState -join '').Trim() -ne 'device')) {
    throw 'The TV is not authorized yet. Accept the debugging prompt on the TV, then run again.'
}

function Read-TvValue([string[]]$Command) {
    $taskResult = & $AdbPath -s $taskSerial shell @Command 2>&1
    [pscustomobject]@{ ExitCode = $LASTEXITCODE; Value = ($taskResult -join "`n").Trim() }
}

$taskReport = [ordered]@{
    CapturedAt = (Get-Date -Format o)
    Connection = $taskSerial
    Properties = [ordered]@{}
    Packages = [ordered]@{}
    SettingsBefore = [ordered]@{}
    Note = 'Read-only snapshot. Presence of VPN components does not prove VPN or streaming compatibility.'
}
foreach ($taskProperty in @('ro.product.model','ro.product.device','ro.product.manufacturer',
    'ro.build.version.release','ro.build.version.sdk','ro.build.display.id','ro.product.cpu.abilist')) {
    $taskReport.Properties[$taskProperty] = Read-TvValue @('getprop', $taskProperty)
}
foreach ($taskPackage in @('app.orchard.tv','com.github.metacubex.clash.meta',
    'com.apple.atve.androidtv.appletv','com.apple.atve.sony.appletv','com.android.vpndialogs',
    'com.tcl.MultiScreenInteraction_TV','com.tcl.cyberui','com.amazon.firetv.youtube')) {
    $taskReport.Packages[$taskPackage] = Read-TvValue @('pm','path',$taskPackage)
}
foreach ($taskSetting in @('enabled_accessibility_services','accessibility_enabled','enabled_notification_listeners')) {
    $taskReport.SettingsBefore[$taskSetting] = Read-TvValue @('settings','get','secure',$taskSetting)
}
$taskReport.SettingsBefore['boot_app_componentname'] = Read-TvValue @('settings','get','system','boot_app_componentname')
$taskFile = Join-Path $taskLocal ('tv-inspection-{0}.json' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$taskReport | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $taskFile -Encoding utf8
Write-Output ('Saved read-only inspection: {0}' -f $taskFile)
$taskReport.Properties | ConvertTo-Json -Depth 3
