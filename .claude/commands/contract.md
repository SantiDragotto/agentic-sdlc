---
name: contract
description: "OPCIONAL — define o actualiza el contract.md de una feature (la interfaz que exponés a otros)"
argument-hint: "[NNN-slug o brief de la feature]"
---

> **Fase OPCIONAL — solo si tu proyecto expone una interfaz que otros consumen** (API, librería, CLI, schema/formato de datos). Si la feature es puramente interna, salteá esta fase: andá directo a `/spec`. GETTING-STARTED explica cómo borrar `/contract`, el template `contract.md` y el agente `e2e-tester` si tu proyecto nunca expone interfaces.

Estás en la fase **Contrato** del flujo SDD (ver `specs/README.md`) — quien expone la interfaz es **dueño del contrato**. Para: $ARGUMENTS

1. Leé `specs/CONSTITUTION.md` y `specs/TEMPLATE/contract.md`.
2. Delegá la exploración + redacción al agente **`solution-designer`**: que recorra la interfaz y las abstracciones existentes (no duplicar), respete las convenciones del proyecto (ver AGENTS.md — IDs, autorización, forma de respuesta/error, cambios de esquema vía `{{MIGRATION_COMMAND}}`) y produzca un borrador de `specs/NNN-slug/contract.md` desde el template.
3. Revisá el borrador y **preguntame hasta que no quede ningún `[VERIFICAR]`**. No escribas código.
4. Dejá `status: proposed`. Pasa a `approved` cuando lo apruebo; a `shipped` recién cuando esté implementado (lo marca `/verify`).
5. **OPCIONAL — multi-repo:** si algún consumidor (paths declarados en `consumers:`) debería enterarse del contrato nuevo/cambiado, avisalo según el checklist de coordinación cross-repo de `specs/README.md`.
