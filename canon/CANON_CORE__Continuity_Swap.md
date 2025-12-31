# CANON_CORE — Continuity & Swap (Chat Rehydration)

## Objetivo
Permitir debate/brainstorm/testes sem perder contexto e sem inchar a sessão.
Swap e reidratação devem ser **autônomos**, com **autorização humana**.

## Artefatos operacionais (VAULT)
- Snapshots: ...\snapshots\
- Manifest: ...\snapshots\manifest.jsonl
- Handoff: arquivo markdown gerado para colar no novo chat

## Regras de Swap
- Coordenadora decide “precisa trocar” com base em critérios (ex.: RAM/lag crescente, risco de colapso, sessão inchada, mudança de etapa).
- Após decisão, pede **autorização do usuário**.
- Depois de autorizado:
  1) gerar snapshot/delta
  2) gerar handoff
  3) abrir novo chat
  4) colar prompt de reidratação (canônico, com caminhos do VAULT + última referência)

## Operação
- Mudanças detectadas: snapshot a cada **15 min** (somente se houver mudanças).
- Modo de trabalho: debate primeiro, execução hard depois.

## Definição de conclusão de Swap
**Swap concluído = manifest.jsonl (tail) contém o delta e o handoff do ciclo atual.**  
Se não aparecer no manifest, registrar no próximo delta como risco operacional e repetir o ciclo (não trocar de chat).

## Definição de conclusão de Swap
**Swap concluído = manifest.jsonl (tail) contém o delta e o handoff do ciclo atual.**  
Se não aparecer no manifest, registrar no próximo delta como risco operacional e repetir o ciclo (não trocar de chat).
