# E:\DBB_EXT\AUTOBOT_DBB_V3_VAULT\_TESTS_CONNECT\run_flask.ps1
$ErrorActionPreference = "Stop"

$baseDir   = $PSScriptRoot
$pyScript  = Join-Path $baseDir "T01_handshake_server.py"

$logDir    = Join-Path $baseDir "logs"
$logFile   = Join-Path $logDir "flask_run.log"
$pidFile   = Join-Path $baseDir "flask.pid"

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
    $r = Invoke-RestMethod -Method Post -Uri $healthUrl -TimeoutSec 2
    return ($r.ok -eq $true)
  } catch {
    return $false
  }
}

function Wait-Health([int]$maxTries = 30, [int]$sleepSec = 1) {
  for ($i=1; $i -le $maxTries; $i++) {
    if (HealthIsUp) { return $true }
    Start-Sleep -Seconds $sleepSec
  }
  return $false
}

# 0) Se a porta 5055 já está LISTENING, adota e sai
$portPid = Get-ListeningPid5055
if ($portPid) {
  Set-Content -Path $pidFile -Value $portPid -Encoding ASCII
  if (HealthIsUp) {
    Log "Flask already running (port 5055 LISTENING PID=$portPid, health ok). Adopted PID and exiting."
  } else {
    Log "WARN: port 5055 LISTENING PID=$portPid but /health not responding yet. Adopted PID and exiting."
  }
  exit 0
}

# 1) Se existe PID file, valida se o processo existe (best-effort). Se existir, mas NÃO há porta, assume stale e limpa.
if (Test-Path $pidFile) {
  $raw = (Get-Content $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1)
  $raw = if ($raw) { $raw.Trim() } else { "" }

  if ($raw -match '^\d+$') {
    $flaskPid = [int]$raw
    try {
      $p = Get-Process -Id $flaskPid -ErrorAction Stop
      # Se processo existe mas porta não está LISTENING, provavelmente é python antigo ou PID reaproveitado
      Log "PID file exists (PID=$flaskPid) but port 5055 is not listening. Cleaning PID file (stale)."
      Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
    } catch {
      Log "PID file exists but process not running. Cleaning PID file."
      Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
    }
  } else {
    Log "Invalid PID file content. Cleaning."
    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
  }
}

# 2) Última checagem: se /health responde sem porta detectada (raro), tenta adotar de novo
if (HealthIsUp) {
  $portPid2 = Get-ListeningPid5055
  if ($portPid2) {
    Set-Content -Path $pidFile -Value $portPid2 -Encoding ASCII
    Log "Flask already running (health ok). Adopted PID=$portPid2 and exiting."
    exit 0
  }
  Log "Flask health ok but could not resolve PID from port 5055. Exiting without pid."
  exit 0
}

# 3) Sobe Flask
Log "Starting Flask: python `"$pyScript`""
$proc = Start-Process -FilePath "python" -ArgumentList "`"$pyScript`"" -WorkingDirectory $baseDir -PassThru -WindowStyle Hidden

# 4) Espera a porta/health subirem (evita corrida com o tunnel)
$ok = Wait-Health -maxTries 30 -sleepSec 1
$portPid3 = Get-ListeningPid5055

if ($portPid3) {
  Set-Content -Path $pidFile -Value $portPid3 -Encoding ASCII
  Log "Flask started and port is listening. Adopted PID from port: $portPid3"
} else {
  # fallback: grava o PID do Start-Process mesmo assim
  Set-Content -Path $pidFile -Value $proc.Id -Encoding ASCII
  Log "WARN: could not resolve LISTENING PID on port 5055. Wrote Start-Process PID=$($proc.Id)"
}

if ($ok) {
  Log "Flask is healthy (/health ok)."
} else {
  Log "WARN: Flask did not become healthy within timeout (30s). Check python/flask logs."
}

exit 0
