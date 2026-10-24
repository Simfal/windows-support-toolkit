#Requires -Version 5.1
<#
.SYNOPSIS
Creates a local Windows inventory report for an IT support home lab.
.DESCRIPTION
Reads system, disk and network configuration using CIM. Writes one HTML report.
It does not repair faults or change Windows settings.
.EXAMPLE
.\Get-SupportReport.ps1 -OpenReport
.EXAMPLE
.\Get-SupportReport.ps1 -LowDiskThreshold 100 -OpenReport
#>
[CmdletBinding()]
param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'reports'),

    [ValidateRange(1, 100)]
    [int]$LowDiskThreshold = 15,

    [switch]$OpenReport
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
    throw 'Run this script on Windows, for example your Windows lab VM.'
}

Write-Host 'Collecting computer information...'
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$computer = Get-CimInstance -ClassName Win32_ComputerSystem
$system = [pscustomobject][ordered]@{
    Computer = $computer.Name
    Windows = $os.Caption
    Version = $os.Version
    'Installed RAM (GiB)' = [math]::Round($computer.TotalPhysicalMemory / 1GB, 1)
    'Last boot' = $os.LastBootUpTime.ToString('yyyy-MM-dd HH:mm')
    'Uptime (hours)' = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours, 1)
}

Write-Host 'Checking fixed disks...'
$disks = @(Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType = 3' |
    ForEach-Object {
        $size = $null
        $free = $null
        $percentage = $null
        $status = 'Unavailable'

        if ($null -ne $_.Size -and $_.Size -gt 0 -and $null -ne $_.FreeSpace) {
            $size = [math]::Round($_.Size / 1GB, 1)
            $free = [math]::Round($_.FreeSpace / 1GB, 1)
            $rawPercentage = ($_.FreeSpace / $_.Size) * 100
            $percentage = [math]::Round($rawPercentage, 1)
            $status = if ($rawPercentage -lt $LowDiskThreshold) { 'Low space' } else { 'OK' }
        }

        [pscustomobject][ordered]@{
            Drive = $_.DeviceID
            'Capacity (GiB)' = $size
            'Free (GiB)' = $free
            'Free (%)' = $percentage
            Status = $status
        }
    })

Write-Host 'Reading network configuration...'
$networkNote = 'Configuration only: connectivity has not been tested.'
$networks = @()
try {
    $networks = @(Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter 'IPEnabled = TRUE' |
        ForEach-Object {
            [pscustomobject][ordered]@{
                Adapter = $_.Description
                'IP addresses' = (@($_.IPAddress) -join ', ')
                Gateways = (@($_.DefaultIPGateway) -join ', ')
                'DNS servers' = (@($_.DNSServerSearchOrder) -join ', ')
                DHCP = $_.DHCPEnabled
            }
        })
}
catch {
    $networkNote = 'Network configuration could not be collected: ' + $_.Exception.Message
}

$systemTable = $system | ConvertTo-Html -Fragment -As List | Out-String
$diskTable = if ($disks.Count -gt 0) {
    $disks | ConvertTo-Html -Fragment | Out-String
} else {
    '<p>No fixed-disk information was returned.</p>'
}
$networkTable = if ($networks.Count -gt 0) {
    $networks | ConvertTo-Html -Fragment | Out-String
} else {
    '<p>No IP-enabled adapter configuration was returned.</p>'
}
Write-Host 'Testing DNS and TCP connectivity...'
$testWebsite = 'www.microsoft.com'

try {
    $addresses = @(
        Resolve-DnsName -Name $testWebsite -Type A -DnsOnly `
            -QuickTimeout -ErrorAction Stop |
            Where-Object { $_.Type -eq 'A' }
    )

    $dnsResult = if ($addresses.Count -gt 0) {
        'Passed'
    } else {
        'No IPv4 addresses returned'
    }
}
catch {
    $dnsResult = 'Failed: ' + $_.Exception.Message
}

try {
    $connected = Test-NetConnection -ComputerName $testWebsite `
        -Port 443 -InformationLevel Quiet `
        -WarningAction SilentlyContinue -ErrorAction Stop

    $tcpResult = if ($connected) { 'Passed' } else { 'Failed' }
}
catch {
    $tcpResult = 'Failed: ' + $_.Exception.Message
}

$networkNote = $networkNote.Replace(
    'Configuration only: connectivity has not been tested.',
    'Configuration snapshot.'
)
$networkNote += " DNS lookup for ${testWebsite}: $dnsResult."
$networkNote += " TCP connection to port 443: $tcpResult."
$networkNoteHtml = [System.Net.WebUtility]::HtmlEncode($networkNote)
$generatedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
$lowDiskCount = @($disks | Where-Object { $_.Status -eq 'Low space' }).Count
$unknownDiskCount = @($disks | Where-Object { $_.Status -eq 'Unavailable' }).Count

$head = @'
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body{font:16px/1.6 "Segoe UI",Arial,sans-serif;background:#f3f5f8;color:#182538;margin:0;padding:32px}
main{max-width:1100px;margin:auto;background:white;padding:32px;border-radius:14px}
h1{margin:0;font-size:30px}h2{margin-top:30px;font-size:21px}
.label{color:#235bc2;font-size:13px;font-weight:700;letter-spacing:.08em}
.muted{color:#526174}.summary{background:#edf3ff;padding:16px;border-radius:8px}
.scroll{overflow-x:auto}table{border-collapse:collapse;width:100%;font-size:14px}
th,td{text-align:left;padding:10px 12px;border-bottom:1px solid #dfe5ef;overflow-wrap:anywhere}
th{background:#f4f7fb}footer{margin-top:28px;color:#526174;font-size:13px}
@media(max-width:600px){body{padding:12px}main{padding:18px}}
</style>
'@

$body = @"
<main>
<p class="label">WINDOWS IT SUPPORT TOOLKIT</p>
<h1>Computer support report</h1>
<p class="muted">Generated $generatedAt</p>
<div class="summary">Low-space disks: <strong>$lowDiskCount</strong>. Disks with unavailable capacity: <strong>$unknownDiskCount</strong>.<br>
Lab threshold: less than $LowDiskThreshold% free space. This is an inventory snapshot.</div>
<h2>Computer information</h2><div class="scroll">$systemTable</div>
<h2>Fixed disks</h2><div class="scroll">$diskTable</div>
<h2>Network configuration</h2><p class="muted">$networkNoteHtml</p><div class="scroll">$networkTable</div>
<footer>Home lab project. Generated reports contain local device and network details.</footer>
</main>
"@

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$suffix = [guid]::NewGuid().ToString('N').Substring(0, 8)
$filename = 'support-report-{0}-{1}.html' -f (Get-Date -Format 'yyyyMMdd-HHmmss'), $suffix
$reportPath = Join-Path $OutputDirectory $filename
ConvertTo-Html -Title 'Computer support report' -Head $head -Body $body |
    Set-Content -LiteralPath $reportPath -Encoding UTF8
$reportPath = (Resolve-Path -LiteralPath $reportPath).Path

Write-Host "Report saved: $reportPath" -ForegroundColor Green
if ($OpenReport) {
    Invoke-Item -LiteralPath $reportPath
}
