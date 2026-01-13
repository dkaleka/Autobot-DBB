$ErrorActionPreference = "Stop"

$baseDir  = $PSScriptRoot
$pidFile  = Join-Path $baseDir "flask.pid"

$logDir  = Join-Path $baseDir "logs"
$logFile = Join-Path $logDir "flask_stop.log"

$healthUrl = "http://127.0.0.1:5055/health"

function Log([string]$msg) {
  if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
  $line = ("{0} | {1}" -f ([DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")), $msg)
  Add-Content -Path $logFile -Value $line -Encoding UTF8
  Write-Host $msg
}

function Get-ListeningPid5055() {
  try {
    $line = (netstat -ano | Select-String ":5055" | Select-String "LISTENING" | Select-Object -First 1).ToString()
    if ($line) {
      # Regex robusto para capturar o último número (PID) na linha, ignorando espaçamento.
      $match = [regex]::Match($line, '(\d+)\s*$')
      if ($match.Success) {
        return [int]$match.Groups[1].Value
      }
    }
  } catch {}
  return $null
}

function HealthIsUp() {
  try {
    Invoke-RestMethod -Method Post -Uri $healthUrl -TimeoutSec 2 | Out-Null
    return $true
  } catch {
    return $false
  }
}

Log "Stopping Flask ..."

# 0) Descobre quem está na porta (referência)
$portPid = Get-ListeningPid5055

# 1) Tenta PID file (mas valida contra a porta 5055)
if (Test-Path $pidFile) {
  $flaskPidRaw = (Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1)
  $flaskPidRaw = if ($flaskPidRaw) { $flaskPidRaw.Trim() } else { "" }

  if ($flaskPidRaw -match '^\d+$') {
    $flaskPid = [int]$flaskPidRaw

    # Se existir PID na porta e for diferente, NÃO mata pelo pidfile
    if ($portPid -and ($portPid -ne $flaskPid)) {
      Log ("PID file says {0} but port 5055 is LISTENING on {1}. Using port PID." -f $flaskPid, $portPid)
      $flaskPid = $portPid
    }

    try {
      $p = Get-Process -Id $flaskPid -ErrorAction Stop
      Log ("Killing PID {0} ({1})" -f $p.Id, $p.ProcessName)
      Stop-Process -Id $p.Id -Force
      Start-Sleep -Milliseconds 300

      # limpa pidfile sempre (ele pode estar velho)
      Remove-Item $pidFile -Force -ErrorAction SilentlyContinue

      if (HealthIsUp) {
        Log "WARN: /health still responds after kill (unexpected)."
      } else {
        Log "OK: Flask stopped (health down)."
      }
      exit 0
    } catch {
      Log "PID file exists but process is not running. Cleaning PID file."
      Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
    }
  } else {
    Log "Invalid PID file content. Cleaning."
    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
  }
}

# 2) Fallback: mata quem estiver LISTENING na porta 5055
if ($portPid) {
  try {
    $p = Get-Process -Id $portPid -ErrorAction Stop
    Log ("Killing PID {0} ({1}) [port 5055 LISTENING]" -f $p.Id, $p.ProcessName)
    Stop-Process -Id $p.Id -Force
    Start-Sleep -Milliseconds 300

    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue

    if (HealthIsUp) {
      Log "WARN: /health still responds after kill (unexpected)."
    } else {
      Log "OK: Flask stopped (health down)."
    }
    exit 0
  } catch {
    Log ("Found port PID {0} but could not kill it. Error: {1}" -f $portPid, $_.Exception.Message)
    exit 1
  }
}

Log "No matching Flask process found."
exit 0
