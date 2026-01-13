# bridge_service.ps1
$ErrorActionPreference = "Stop"

$baseDir = $PSScriptRoot
$logDir  = Join-Path $baseDir "logs"
$logFile = Join-Path $logDir "bridge_service.log"

function Log([string]$msg) {
  if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
  $line = ("{0} | {1}" -f ([DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")), $msg)
  Add-Content -Path $logFile -Value $line -Encoding UTF8
  # Também escreve no host para visibilidade quando executado interativamente
  Write-Host $msg
}

# Invocador de script com log robusto e tratamento de erro
function Invoke-Script([string]$scriptName) {
    $scriptPath = Join-Path $baseDir $scriptName
    Log "--- Executing script: $scriptName ---"

    # Executa o script e captura toda a saída
    $output = & powershell.exe -ExecutionPolicy Bypass -File $scriptPath *>&1 | Out-String

    # A variável $LASTEXITCODE é populada automaticamente após a execução de um programa externo (.exe)
    $exitCode = $LASTEXITCODE

    if ($output -and $output.Trim()) {
        $output.Trim() -split "`r?`n" | ForEach-Object { Log "  | $_" }
    }

    if ($exitCode -eq 0) {
        Log "--- Finished script: $scriptName (SUCCESS) ---"
        return $true
    } else {
        Log "--- Finished script: $scriptName (FAILED with Exit Code: $exitCode) ---"
        return $false
    }
}

Log "BRIDGE SERVICE START"

# Inicia os componentes com log detalhado e tratamento de erro
if (-not (Invoke-Script "run_flask.ps1")) {
    Log "ERROR: Failed to start Flask. Aborting bridge service."
    exit 1
}

if (-not (Invoke-Script "run_tunnel.ps1")) {
    Log "ERROR: Failed to start Tunnel. Aborting bridge service."
    exit 1
}

# Inicia o watchdog como o processo principal e bloqueante
Log "All components started successfully. Starting watchdog (blocking)..."
# A saída do watchdog já é logada em seu próprio arquivo, então aqui só executamos.
& (Join-Path $baseDir "watchdog_tunnel.ps1")
