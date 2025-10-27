<# 
Simple network change tracker for Windows
Usage (as Admin): powershell -ExecutionPolicy Bypass -File .\track_net_windows.ps1 [C:\NetTrack]
#>
param(
  [string]$Base = "C:\NetTrack"
)
New-Item -ItemType Directory -Force -Path $Base | Out-Null
$cur = Join-Path $Base "netstat_current.txt"
$prev = Join-Path $Base "netstat_prev.txt"
$log = Join-Path $Base "changes.log"

netstat -ano > $cur
if (Test-Path $prev) {
  $d = (Compare-Object (Get-Content $prev) (Get-Content $cur) -SyncWindow 0)
  if ($d) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $log -Value "`n=== Change at $ts ==="
    $d | Out-String | Add-Content -Path $log
  }
}
Move-Item -Force $cur $prev
Write-Host "Checked. Log: $log"
