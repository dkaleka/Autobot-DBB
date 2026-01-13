# run_tunnel.ps1
$ErrorActionPreference = "Stop"

$baseDir = $PSScriptRoot
$logDir  = Join-Path $baseDir "logs"
$logFile = Join-Path $logDir "tunnel_run.log"
$tunnelPidFile = Join-Path $baseDir "tunnel.pid"

$tunnelName   = "dbb-bridge-5055"
$originHealth = "http://127.0.0.1:5055/health"

$maxWaitFlaskSeconds = 60
$pollEverySeconds    = 2

function Log([string]$msg) {
  if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
  $line = ("{0} | {1}" -f ([DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")), $msg)
  Add-Content -Path $logFile -Value $line -Encoding UTF8
  Write-Host $msg
}

function Resolve-CloudflaredPath {
  $cmd = Get-Command "cloudflared.exe" -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source -and (Test-Path $cmd.Source)) { return $cmd.Source }

  $fallback = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links\cloudflared.exe"
  if (Test-Path $fallback) { return $fallback }

  return $null
}

function Get-TunnelRunProcesses {
  $rx = "(?i)\btunnel\s+run\s+$([regex]::Escape($tunnelName))\b"
  Get-CimInstance Win32_Process -Filter "Name='cloudflared.exe'" |
    Where-Object { $_.CommandLine -match $rx }
}

$cloudflaredExe = Resolve-CloudflaredPath
if (!$cloudflaredExe) {
  Log "ERROR: cloudflared.exe not found in PATH and not found in WinGet Links. Aborting."
  exit 1
}
Log "cloudflared resolved to: $cloudflaredExe"

# 1) Anti-dup forte (somente pro tunnelName)
$running = Get-TunnelRunProcesses
if ($running) {
  $pids = ($running | Select-Object -ExpandProperty ProcessId) -join ","
  Log "cloudflared tunnel already running for '$tunnelName' (PID(s): $pids). Exiting."
  exit 0
}

# 2) Espera Flask ficar OK
$maxTries = [Math]::Ceiling($maxWaitFlaskSeconds / $pollEverySeconds)
Log "Waiting for Flask health at $originHealth (up to ${maxWaitFlaskSeconds}s)..."

$flaskOk = $false
for ($i=1; $i -le $maxTries; $i++) {
  try {
    $r = Invoke-RestMethod -Method Post -Uri $originHealth -TimeoutSec 2
    if ($r -and $r.ok -eq $true) { $flaskOk = $true; break }
  } catch {}
  Start-Sleep -Seconds $pollEverySeconds
}

if (!$flaskOk) {
  Log "ERROR: Flask health did not respond in time. Aborting tunnel start."
  exit 1
}
Log "Flask is up (health ok)."

# 3) Start tunnel (http2 + ipv4) em background, grava PID
$argList = "--protocol http2 --edge-ip-version 4 tunnel run $tunnelName"
Log "Starting cloudflared: $argList"

$p = Start-Process -FilePath $cloudflaredExe -ArgumentList $argList -WorkingDirectory $baseDir -PassThru -WindowStyle Hidden
Set-Content -Path $tunnelPidFile -Value $p.Id -Encoding ASCII
Log "Tunnel process started with PID=$($p.Id). Wrote $tunnelPidFile"

# 4) Validação Pós-Inicialização
Log "Verifying process stability..."
Start-Sleep -Seconds 3 # Dá tempo para o processo falhar (ex: erro de auth)
try {
    Get-Process -Id $p.Id -ErrorAction Stop | Out-Null
    Log "Process PID=$($p.Id) is stable. Tunnel is running."
    exit 0
} catch {
    Log "ERROR: Tunnel process with PID=$($p.Id) terminated unexpectedly after start."
    Log "Check cloudflared logs or configuration. Cleaning up stale PID file."
    Remove-Item $tunnelPidFile -Force -ErrorAction SilentlyContinue
    exit 1 # Sai com erro
}