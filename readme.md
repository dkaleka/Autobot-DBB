3) Explicação técnica detalhada (o que foi feito)
Estrutura de pastas (padrão)

Base do stack:

E:\DBB_EXT\AUTOBOT_DBB_V3_VAULT\_TESTS_CONNECT\
  T01_handshake_server.py
  run_flask.ps1
  stop_flask.ps1
  flask.pid
  run_tunnel.ps1
  stop_tunnel.ps1
  tunnel.pid
  watchdog_tunnel.ps1
  logs\
    flask_run.log
    flask_stop.log
    tunnel_run.log
    tunnel_stop.log
    tunnel_watchdog.log
    cloudflared_stdout.log
    cloudflared_stderr.log
  queue_in\
  queue_out\

O que cada componente resolve

Flask (T01_handshake_server.py)

Serviço local em 127.0.0.1:5055.

Endpoint /health retorna JSON ok:true.

É o “origin” do Cloudflare Tunnel.

run_flask.ps1

Idempotente:

se já está rodando (pid file válido) → sai

se /health responde mas pid file faltando → “adota” PID via porta 5055 e grava flask.pid

Sobe Flask em background e grava flask.pid.

stop_flask.ps1

Para Flask de forma determinística:

tenta flask.pid

fallback: encontra PID via netstat :5055 LISTENING

Limpa flask.pid.

run_tunnel.ps1 (forte)

Não inicia se Flask não está saudável (evita 1033/502/loop).

Anti-dup forte por CommandLine, não por nome do processo (não mata/impede outros usos de cloudflared).

Força --protocol http2 --edge-ip-version 4:

evita o problema que você viu no QUIC/UDP/IPv6 (rede inacessível / timeout).

Roda em background com logs (cloudflared_stdout.log, cloudflared_stderr.log) e grava tunnel.pid.

stop_tunnel.ps1 (forte)

Mata só cloudflared.exe ... tunnel run dbb-bridge-5055.

Prioriza tunnel.pid, mas confirma CommandLine antes de matar.

watchdog_tunnel.ps1

Observa saúde pública (domínio).

Só reinicia se:

falha X vezes seguidas

Flask local está ok (evita flapping)

Usa powershell.exe para executar stop/run (não depende do seu PS7).

4) Instruções de uso (operacional)
Como iniciar (manual, ordem correta)

Na pasta _TESTS_CONNECT:

Flask:

powershell.exe -ExecutionPolicy Bypass -File .\run_flask.ps1


Tunnel:

powershell.exe -ExecutionPolicy Bypass -File .\run_tunnel.ps1


Teste público:

Invoke-RestMethod -Method Post -Uri "https://bridge.meidaledolls.com.br/health"


(Opcional) Watchdog:

powershell.exe -ExecutionPolicy Bypass -File .\watchdog_tunnel.ps1

Como encerrar (manual)

Tunnel:

powershell.exe -ExecutionPolicy Bypass -File .\stop_tunnel.ps1


Flask:

powershell.exe -ExecutionPolicy Bypass -File .\stop_flask.ps1

Como checar status rápido

Flask:

Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:5055/health"
netstat -ano | findstr ":5055"
Get-Content .\flask.pid


Tunnel:

Invoke-RestMethod -Method Post -Uri "https://bridge.meidaledolls.com.br/health"
Get-CimInstance Win32_Process -Filter "Name='cloudflared.exe'" | Select ProcessId,CommandLine
Get-Content .\tunnel.pid

Qual PowerShell usar (importante)

Os scripts foram escritos para rodar via powershell.exe (Windows PowerShell, fundo azul) porque:

Scheduled Task normalmente chama isso.

Comportamento e PATH ficam mais previsíveis.

Você pode chamar a partir do PS7 (pwsh) sem problema desde que invoque powershell.exe -File ... (como já está fazendo).



Debug de erro (502/1033/loop)

Checklist de 30s:

Flask local está vivo?

Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:5055/health"


Se falhar → rode run_flask.ps1 e veja logs\flask_run.log.

Tunnel está rodando com http2+ipv4?

Get-CimInstance Win32_Process -Filter "Name='cloudflared.exe'" | Select ProcessId,CommandLine


Procure --protocol http2 --edge-ip-version 4 tunnel run dbb-bridge-5055

Logs do cloudflared:

Get-Content .\logs\cloudflared_stderr.log -Tail 120
Get-Content .\logs\cloudflared_stdout.log -Tail 120


Se estiver em QUIC/UDP dando “rede inacessível”:

pare e suba com run_tunnel.ps1 (que força http2/ipv4).




-------------------------------------------------------------
