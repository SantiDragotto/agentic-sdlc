# `TEMPLATE/` — plantillas de artefactos SDD

Las 4 plantillas que componen una feature. **Al abrir una feature, copialas a `specs/NNN-slug/`** (`NNN` = próximo libre del `INDEX.md`, `slug` = kebab-case corto) y completalas fase por fase. No edites las de acá: son los moldes en blanco.

| Archivo | Qué define | Cuándo |
|---|---|---|
| `spec.md` | El **QUÉ y POR QUÉ**: problema, comportamiento observable y **criterios de aceptación** verificables. | `/spec` — primera fase de toda feature. |
| `plan.md` | El **CÓMO**: enfoque técnico, qué se reutiliza, cambios archivo por archivo, riesgos. | `/plan` — tras `spec.md` en `approved`. |
| `tasks.md` | La **descomposición**: checklist atómica, cada tarea atada a un criterio de aceptación (col. "Cubre AC"). | `/tasks` — tras `plan.md` en `approved`. |
| `contract.md` *(OPCIONAL)* | La **interfaz** que exponés a otros: firmas, campos, errores, estados, auth. Solo si tu proyecto expone algo hacia afuera. | `/contract` — borralo si no exponés interfaz. |

## Lifecycle de cada artefacto

El `status` vive en el frontmatter. Una sola palabra canónica; los matices van tras un guion.

| Artefacto | Estados |
|---|---|
| `spec.md` | `draft` → `approved` → `in-progress` → `done` |
| `plan.md` | `draft` → `approved` |
| `contract.md` *(OPCIONAL)* | `proposed` → `approved` → `shipped` |

`tasks.md` no lleva `status` propio: su estado real es el avance de la checklist (cada tarea se tilda al completarla).

> El proceso canónico, los criterios de salida de cada fase y los marcadores (`[VERIFICAR]`, `[IA-DECIDIÓ]`, `{{TOKEN}}`) están en `../README.md`. Para ver cada artefacto **ya completado**, mirá `../000-EXAMPLE-feature/`.
