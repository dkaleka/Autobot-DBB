# DECISION_LEDGER (Autobot-DBB)
Regra: toda DECISION ganha ID e entra aqui em até 30s.  
Status: proposta | aprovada | pending | live | archived  
Severidade: S1 (crítico) → S4 (baixo)

Definição operacional:
**Swap concluído = manifest.jsonl (tail) contém o delta e o handoff do ciclo atual.**

---

## DEC-20251231-001 | severidade: S1 | status: live
**Swap só conta como concluído se delta + handoff aparecerem no manifest.jsonl (tail).**  
Motivo: elimina “falso vazio” e garante auditabilidade do estado.  
Links: delta=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T14-38-16Z__delta__6083c518.md | handoff=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T20-05-32Z__handoff__3fe62ca3.md | canon=pending (CANON_CORE__Continuity_Swap.md)  
Próxima ação: atualizar CANON_CONTINUITY com a regra do manifest.

## DEC-20251231-002 | severidade: S1 | status: live
**Procedimento Swap v1.1 (30–60s) + Regra de Ouro (falhou? não troca; gera delta de falha).**  
Motivo: reduz risco de perda de estado e troca inconsistente de chat.  
Links: delta=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T14-38-16Z__delta__6083c518.md | handoff=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T20-05-32Z__handoff__3fe62ca3.md | canon=pending (CANON_CORE__Continuity_Swap.md)  
Próxima ação: promover texto final do Swap Procedure v1.1 para CANON.

## DEC-20251231-003 | severidade: S2 | status: live
**Storage Contract: Git manda no produto/CANON; VAULT manda na operação (snapshots/logs/filas/segredos).**  
Motivo: define precedência e evita divergência silenciosa.  
Links: delta=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T14-38-16Z__delta__6083c518.md | handoff=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T20-05-32Z__handoff__3fe62ca3.md | canon=canon/CANON_CORE__Storage_Contract.md  
Próxima ação: incluir 1 parágrafo “mapa de diretórios” no Storage Contract (repo vs vault).

## DEC-20251231-004 | severidade: S2 | status: live
**Governança de execução: user-tasks exigem DBB_RUN: yes + modo ARMED no overlay + allowlist.**  
Motivo: segurança operacional e controle humano.  
Links: delta=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T14-38-16Z__delta__6083c518.md | handoff=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T20-05-32Z__handoff__3fe62ca3.md | canon=pending  
Próxima ação: canonizar como seção “Execution Governance” (Storage Contract ou Continuity).

## DEC-20251231-005 | severidade: S3 | status: live
**Taxonomia/processo fixo:** IDEA → HYPOTHESIS → CRITIQUE → EXPERIMENT → RESULT → (PROMOTE | ARCHIVE | REVISE | NEW_EXPERIMENT).  
Motivo: evita caos e garante rastreabilidade de pensamento/experimento.  
Links: delta=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T14-38-16Z__delta__6083c518.md | handoff=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T20-05-32Z__handoff__3fe62ca3.md | canon=canon/CANON_CORE__Taxonomy_Process.md  
Próxima ação: manter índice e exemplos mínimos no CANON (sem inflar).

## DEC-20251231-006 | severidade: S3 | status: live
**CRITIQUE é tipo separado + extras até 600 chars quando não cabe no schema.**  
Motivo: flexibilidade sem quebrar o formato.  
Links: delta=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T14-38-16Z__delta__6083c518.md | handoff=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T20-05-32Z__handoff__3fe62ca3.md | canon=canon/CANON_CORE__Taxonomy_Process.md  
Próxima ação: reforçar o limite e quando usar extras (regra 1 linha).

## DEC-20251231-007 | severidade: S3 | status: live
**NOTE não expira, mas exige tag (risk|insight|question|reference) + revisão a cada 3 dias (ou adia +3d).**  
Motivo: evita “lixo eterno” e mantém utilidade operacional.  
Links: delta=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T14-38-16Z__delta__6083c518.md | handoff=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T20-05-32Z__handoff__3fe62ca3.md | canon=canon/CANON_CORE__Taxonomy_Process.md  
Próxima ação: definir rotina: overdue list paginado; TOP=maior overdue (10).

## DEC-20251231-008 | severidade: S3 | status: live
**Regra de DECISION:** só vira DECISION se afetar contrato/segurança, taxonomia, swap/continuidade, arquitetura futura, ou prioridade > 1 dia.  
Motivo: evita canonização demais e mantém foco.  
Links: delta=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T14-38-16Z__delta__6083c518.md | handoff=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T20-05-32Z__handoff__3fe62ca3.md | canon=pending  
Próxima ação: canonizar a regra “o que é DECISION” (CANON_INDEX ou Storage Contract).

## DEC-20251231-009 | severidade: S3 | status: live
**Críticas externas:** padrão 2; 3ª deve ser modelo diferente; até 5; críticos competentes; preferidos: DeepSeek/Gemini/ChatGPT; reservas: Grok/Copilot/Claude.  
Motivo: validação pragmática sem virar circo.  
Links: delta=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T14-38-16Z__delta__6083c518.md | handoff=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T20-05-32Z__handoff__3fe62ca3.md | canon=pending  
Próxima ação: criar mini CANON “External Critique Protocol” ou adicionar ao CANON_INDEX.

## DEC-20251231-010 | severidade: S2 | status: live
**Preferência do sistema:** Robustez > baixa latência; missões mínimas em sequência (não inicia próxima sem fechar anterior).  
Motivo: disciplina de execução (evita abandonar metade).  
Links: delta=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T14-38-16Z__delta__6083c518.md | handoff=E:\DBB_EXT\autobot_dbb_v3_VAULT\snapshots\2025-12-31T20-05-32Z__handoff__3fe62ca3.md | canon=pending  
Próxima ação: promover para CANON_INDEX como princípio de operação.

