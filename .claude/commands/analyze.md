---
name: analyze
description: Chequea consistencia spec ↔ contract ↔ plan ↔ tasks ↔ convenciones del proyecto antes de implementar
argument-hint: "[NNN-slug]"
---

Estás en la fase **Analyze** del flujo SDD (ver `specs/README.md`). Para: $ARGUMENTS

Delegá al agente **`spec-analyst`** (read-only) el chequeo cruzado de `spec.md`, `plan.md`, `tasks.md` y —si la feature expone una interfaz— `contract.md`. Que reporte, sin tocar código:

1. **Cobertura de AC:** ¿cada criterio de aceptación tiene al menos una tarea que lo cubre? Listá los AC sin cobertura.
2. **Scope creep:** ¿hay tareas que no mapean a ningún AC? Listalas para recortar o justificar.
3. **Consistencia con el contrato (OPCIONAL — solo si hay `contract.md`):** ¿el plan usa la interfaz (endpoints/firmas/campos/formato) tal como la define el `contract.md`? ¿El contract respeta las convenciones del proyecto (ver AGENTS.md)?
4. **Cumplimiento de gobernanza:** ¿algo viola `specs/CONSTITUTION.md`, `AGENTS.md` o `CLAUDE.md`? (ej.: salteo de una abstracción reusable, invariante de dominio re-implementado a mano, cambio de esquema fuera de `{{MIGRATION_COMMAND}}`, falta de tests obligatorios).

Salida: lista de inconsistencias a corregir ANTES de implementar. Si todo cierra, decilo y dá luz verde.
