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

## Qué queda al cerrar

`plan.md` y `tasks.md` son andamio: **se borran** cuando la spec pasa `/verify`. De `spec.md` quedan §1, §2, §4 y §6; de `contract.md`, la interfaz con su §8 en una línea. El resto (análisis, preguntas, notas, supuestos, pendientes, criterios de salida) sale sin renumerar. Lo hace la skill `spec-sanitize --cierre`; la regla está en `../CONSTITUTION.md §6`. Por eso las notas de cada plantilla dicen qué es durable y qué no: escribí desde el día uno lo durable como regla o criterio.

> El proceso canónico, los criterios de salida de cada fase y los marcadores (`[VERIFICAR]`, `[IA-DECIDIÓ]`, `{{TOKEN}}`) están en `../README.md`. Para ver cada artefacto **ya completado**, mirá `../000-EXAMPLE-abierta/` (a mitad de construcción) y `../000-EXAMPLE-cerrada/` (la misma feature después de `/verify`).
