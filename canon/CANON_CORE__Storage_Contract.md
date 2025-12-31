# CANON_CORE — Storage Contract (Git vs VAULT)

## Princípio
- **Git = fonte de verdade do produto e do CANON**
  - Código, contratos canônicos, documentação canônica.
- **VAULT = fonte de verdade da operação**
  - Snapshots, manifest, logs, fila de results, segredos/tokens, artefatos efêmeros.

## Layout mínimo (Windows atual)
- Repo (Git): E:\DBB_EXT\autobot_dbb_v3\
  - CANON: E:\DBB_EXT\autobot_dbb_v3\canon\
- VAULT (operação): E:\DBB_EXT\autobot_dbb_v3_VAULT\
  - Snapshots: ...\snapshots\
  - Manifest: ...\snapshots\manifest.jsonl
  - Logs: ...\logs\...
  - Queue results: ...\queue\results\
  - Secrets: ...\secrets\ (NUNCA vai para o Git)

## Regras de escrita/leitura
- Qualquer automação que **salve** algo deve decidir:
  1) É canônico e estável? -> Git (via PR/commit)
  2) É operacional/temporário/estado? -> VAULT
- Tokens/segredos **sempre**: VAULT (secrets/).

## Anti-confusão (resumo)
- Git: “o que é o DBB”
- VAULT: “o que aconteceu e o que está rodando agora”
