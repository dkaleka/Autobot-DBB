# watchdog_tunnel.ps1
$ErrorActionPreference = "Stop"

$baseDir = $PSScriptRoot
$logDir  = Join-Path $baseDir "logs"
$logFile = Join-Path $logDir "tunnel_watchdog.log"

$publicHealth = "https://bridge.meidaledolls.com.br/health"
$originHealth = "http://127.0.0.1:5055/health"

$threshold = 3
$everySec  = 20

function Log([string]$msg) {
  if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
  $line = ("{0} | {1}" -f ([DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")), $msg)
  Add-Content -Path $logFile -Value $line -Encoding UTF8
  Write-Host $msg
}

# Invocador de script com log robusto
function Invoke-Script([string]$scriptName) {
    $scriptPath = Join-Path $baseDir $scriptName
    Log "--- Executing script: $scriptName ---"
    # O operador *>&1 redireciona TODOS os streams (stdout, error, warning, etc.) para o stream de sucesso para captura
    $output = & $scriptPath *>&1 | Out-String
    if ($output -and $output.Trim()) {
        # Loga a saída de múltiplas linhas com indentação para clareza
        $output.Trim() -split "`r?`n" | ForEach-Object { Log "  | $_" }
    }
    Log "--- Finished script: $scriptName ---"
}

function Test-Health([string]$url) {
  try {
    $r = Invoke-RestMethod -Method Post -Uri $url -TimeoutSec 6
    return ($r -and $r.ok -eq $true)
  } catch { return $false }
}

function Tunnel-Running {
  $rx = "(?i)\btunnel\s+run\s+dbb-bridge-5055\b"
  $p = Get-CimInstance Win32_Process -Filter "Name='cloudflared.exe'" |
        Where-Object { $_.CommandLine -match $rx } |
        Select-Object -First 1
  return [bool]$p
}

Log "WATCHDOG START | public=$publicHealth | threshold=$threshold | every=${everySec}s"

$fails = 0
while ($true) {
  $pubOk = Test-Health $publicHealth

  if ($pubOk) {
    if ($fails -gt 0) { Log "Public health OK (recovered). Resetting fail counter." }
    $fails = 0
  } else {
    $fails++
    Log "Public health FAIL ($fails/$threshold)"

    # Se o túnel não está rodando (crash), tenta uma recuperação imediata sem esperar o threshold.
    if (-not (Tunnel-Running)) {
      Log "Tunnel process is not running. Attempting immediate recovery..."
      if (Test-Health $originHealth) {
        Log "Origin is OK. Starting tunnel."
        Invoke-Script "run_tunnel.ps1"
      } else {
        Log "Origin health FAIL. Starting Flask."
        Invoke-Script "run_flask.ps1"
      }
      # Pula para a próxima iteração após a tentativa de recuperação.
      Start-Sleep -Seconds $everySec
      continue
    }

    # Se o túnel está rodando mas a saúde pública está falhando, espera atingir o threshold.
    if ($fails -ge $threshold) {
      Log "Failure threshold reached. Diagnosing and attempting recovery..."
      $originOk = Test-Health $originHealth
      if (-not $originOk) {
        Log "RECOVERY: Origin health FAIL. Starting Flask. Won't restart tunnel to avoid flapping."
        Invoke-Script "run_flask.ps1"
        $fails = 0 # Reseta o contador após a ação
      } else {
        Log "RECOVERY: Origin health OK but public health is failing. Restarting tunnel."
        Invoke-Script "stop_tunnel.ps1"
        Start-Sleep -Seconds 2
        Invoke-Script "run_tunnel.ps1"
        $fails = 0 # Reseta o contador após a ação
      }
    }
  }

  Start-Sleep -Seconds $everySec
}
