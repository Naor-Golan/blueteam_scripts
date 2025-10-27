<# 
Baseline snapshot for Windows (quick triage)
Usage (as Admin): powershell -ExecutionPolicy Bypass -File .\baseline_windows.ps1 [C:\Baselines]
#>
param(
  [string]$OutRoot = "C:\Baselines"
)
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$outdir = Join-Path $OutRoot $ts
New-Item -ItemType Directory -Force -Path $outdir | Out-Null

# System identity & time
$sysInfo = @()
$sysInfo += (Get-ComputerInfo | Out-String)
$sysInfo += "`n===== date ====="
$sysInfo += (Get-Date | Out-String)
$sysInfo | Out-File -Encoding UTF8 "$outdir\system_info.txt"

# Users
net user | Out-File -Encoding UTF8 "$outdir\net_user.txt"
Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue | 
  Select-Object Name, ObjectClass | Format-Table | Out-String | 
  Out-File -Encoding UTF8 "$outdir\local_admins.txt"

# Processes
tasklist /v > "$outdir\tasklist.txt"

# Services
Get-Service | Sort-Object Name | Select Name,Status,StartType | 
  Export-Csv "$outdir\services.csv" -NoTypeInformation -Encoding UTF8

# Scheduled Tasks
schtasks /query /fo LIST /v > "$outdir\scheduled_tasks.txt"

# Network
netstat -ano > "$outdir\netstat_ano.txt"
Get-NetIPConfiguration | Format-List | Out-File -Encoding UTF8 "$outdir\net_ipconfig.txt"
Get-NetRoute | Sort-Object DestinationPrefix | Format-Table | Out-String | 
  Out-File -Encoding UTF8 "$outdir\net_routes.txt"

# Quick registry exports (optional, fast)
reg export "HKLM\SOFTWARE" "$outdir\HKLM_SOFTWARE.reg" /y | Out-Null
reg export "HKLM\SYSTEM"   "$outdir\HKLM_SYSTEM.reg" /y | Out-Null

Write-Host "Baseline saved to $outdir"
