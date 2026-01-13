# stop_tunnel.ps1
$ErrorActionPreference = "Stop"

$baseDir = $PSScriptRoot
$logDir  = Join-Path $baseDir "logs"
$logFile = Join-Path $logDir "tunnel_stop.log"
$tunnelPidFile = Join-Path $baseDir "tunnel.pid"

$tunnelName = "dbb-bridge-5055"

function Log([string]$msg) {
  if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
  $line = ("{0} | {1}" -f ([DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")), $msg)
  Add-Content -Path $logFile -Value $line -Encoding UTF8
  Write-Host $msg
}

function Matches-TunnelRun([string]$cmdline) {
  $rx = "(?i)\btunnel\s+run\s+$([regex]::Escape($tunnelName))\b"
  return ($cmdline -match $rx)
}

function Get-TunnelRunProcesses {
  Get-CimInstance Win32_Process -Filter "Name='cloudflared.exe'" |
    Where-Object { Matches-TunnelRun $_.CommandLine }
}

Log "Stopping cloudflared tunnel run $tunnelName ..."

# 1) Preferência: PID file (se existir)
if (Test-Path $tunnelPidFile) {
  $pidText = (Get-Content $tunnelPidFile -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
  if ($pidText -match '^\d+$') {
    $tunnelPid = [int]$pidText
    try {
      $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$tunnelPid" -ErrorAction Stop
      if ($proc -and $proc.Name -ieq "cloudflared.exe" -and (Matches-TunnelRun $proc.CommandLine)) {
        Log ("Killing PID {0} | {1}" -f $proc.ProcessId, $proc.CommandLine)
        Stop-Process -Id $proc.ProcessId -Force
        Remove-Item $tunnelPidFile -Force -ErrorAction SilentlyContinue
        Log "Stopped via tunnel.pid."
        exit 0
      } else {
        Log "tunnel.pid points to a process that is not the target tunnel. Cleaning tunnel.pid."
        Remove-Item $tunnelPidFile -Force -ErrorAction SilentlyContinue
      }
    } catch {
      Log "tunnel.pid exists but process not running. Cleaning tunnel.pid."
      Remove-Item $tunnelPidFile -Force -ErrorAction SilentlyContinue
    }
  } else {
    Log "Invalid tunnel.pid content. Cleaning."
    Remove-Item $tunnelPidFile -Force -ErrorAction SilentlyContinue
  }
}

# 2) Fallback: mata por CommandLine (somente o tunnelName)
$matches = Get-TunnelRunProcesses
if (!$matches) {
  Log "No matching cloudflared tunnel run process found for tunnel '$tunnelName'. Nothing to stop."
  exit 0
}

$killed = 0
foreach ($m in $matches) {
  try {
    Log ("Killing PID {0} | {1}" -f $m.ProcessId, $m.CommandLine)
    Stop-Process -Id $m.ProcessId -Force
    $killed++
  } catch {
    Log ("Failed to kill PID {0}: {1}" -f $m.ProcessId, $_.Exception.Message)
  }
}

Log ("Stopped {0} cloudflared process(es)." -f $killed)
exit 0
