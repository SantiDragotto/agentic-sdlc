---
name: plan
description: Genera el plan técnico (CÓMO) de una spec ya aprobada
argument-hint: "[NNN-slug]"
---

Estás en la fase **Plan** del flujo SDD (ver `specs/README.md`). Para la spec: $ARGUMENTS

1. Leé `specs/CONSTITUTION.md`, la `spec.md` (debe estar `approved`) y, si existe, su `contract.md` referenciado. Si la spec todavía no está `approved`, frená y avisá: no se planifica sobre una spec sin aprobar.
2. Delegá al agente **`solution-designer`**: que explore el repo a fondo para listar qué se **reutiliza/extiende** (la casa natural existente — CONSTITUTION §3, reuso-primero), y genere `specs/NNN-slug/plan.md` desde el template: enfoque, reuso, cambios por archivo y módulo, datos/persistencia (¿hace falta `{{MIGRATION_COMMAND}}`?), autorización, tests, riesgos.
3. **Antes de presentarme el plan, corré el protocolo `clarify`** (skill `clarify`) sobre las decisiones de diseño — enfoque/alternativas técnicas · reuso vs. crear · persistencia/modelo de datos · autorización · trade-offs y **complejidad** (toda abstracción/dependencia nueva) · dependencias entre repos/módulos. El `solution-designer` produce las preguntas (con default sugerido + la opción "que decida la IA"); el hilo principal me las presenta. Lo que **delego en la IA** se aplica con su default y queda registrado en `plan.md §7` como **`[IA-DECIDIÓ]`** (no bloquea); lo que queda abierto va como **`[VERIFICAR]`** (bloquea aprobación). Si no hay ambigüedades en esta fase, declaralo explícito.
4. No escribas código de la feature todavía. Presentame el plan para aprobación.
