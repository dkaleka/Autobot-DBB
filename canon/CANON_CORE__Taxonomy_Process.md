# CANON_CORE — Taxonomy & Process

## Tipos (fixos)
- IDEA (pré-hypothesis)
- HYPOTHESIS
- CRITIQUE (tipo separado)
- EXPERIMENT
- RESULT
- TASK
- NOTE
- DECISION

## Ciclo de desenvolvimento (HYPOTHESIS)
IDEA -> HYPOTHESIS -> CRITIQUE(s) -> EXPERIMENT -> RESULT -> (PROMOTE | ARCHIVE)
- Pode morrer em qualquer fase.
- "PROMOTE" só é permitido se existir RESULT.

### CRITIQUE
- Padrão: 2 críticas (pode ir até 5 se for curto; 3ª, quando usada, deve ser de **modelo diferente** das 2 primeiras).
- Critérios de escolha: “IA competente no assunto específico”.
- Prompt de crítica deve pedir formato padronizado (pontos fortes, riscos, falhas, sugestões e veredito).

### EXPERIMENT
- Regra: **1 métrica + 1 teste** por experimento.
- Resultado esperado do experimento: promote | revise | archive | new_experiment (define antes de rodar).

## NOTE
- NOTE não expira, mas exige tag obrigatória: isk | insight | question | reference
- Revisitada a cada **3 dias**:
  - muda status, ou adia +3 dias, ou vira TASK/HYPOTHESIS

## Overdue (UI)
- Mostrar **todas, paginado**
- Badge apenas (sem mudança visual além do badge)
- “Top 10” = maior overdue

## DECISION (quando vira DECISION)
Só vira DECISION se afetar pelo menos 1:
- Contratos/segurança (token, allowlist, governança)
- Taxonomia/processo (estágios, regras, overdue)
- Swap/continuidade (gatilhos, handoff, reidratação)
- Arquitetura futura (Actions/API/NGROK)
- Muda prioridade por mais de 1 dia

DECISION não tem teto de quantidade, mas tem **severidade**.
