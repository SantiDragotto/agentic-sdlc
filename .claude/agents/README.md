# `.claude/agents/`

Subagentes especializados de Claude Code. Cada agente vive en `<name>.md` con frontmatter y system prompt propio.

## Cuándo crear un agente (vs skill)

Elegí **agente** cuando la tarea cumple TODAS estas condiciones:

- **Multi-paso autónomo** — el agente itera por su cuenta sin pedir confirmación.
- **Context isolation valiosa** — la salida es extensa y no aporta a la conversación principal (logs, JSON, output de herramientas largas).
- **Trabajo largo** — minutos, no segundos.

Si dudás, empezá como skill (`.claude/skills/`) y promové a agente sólo si crece en autonomía.

## Frontmatter requerido

```yaml
---
name: <kebab-case>
description: <cuándo se invoca — Claude principal lo lee para decidir delegar>
tools: <lista separada por comas: Read, Grep, Bash, Edit, Write, ...>
model: <sonnet | opus | haiku>
---
```

## Convenciones

- Nombre: kebab-case, sustantivo o sustantivo-verbo (`spec-analyst`, `e2e-tester`).
- **Rol profesional (convención):** cada agente **encarna un rol profesional acorde a su etapa** del SDLC (Analista de Requerimientos, Arquitecto, QA, V&V, etc.). La **primera línea de su system prompt declara ese rol** de forma destacada — no es decorativo: orienta el criterio del agente y el tono de su salida. Mantené esa línea como primera del prompt al crear o editar un agente.
- System prompt: seguí la convención de idioma del repo para agentes internos (acá, español).
- Si el agente escribe logs persistentes, definir convención de path en su prompt (ej. `.claude/agents/<name>/test-runs/`).
- Si tiene "reglas duras" no negociables, listarlas al principio del prompt.

## Activos en este repo

### Agentes SDD (uno por etapa del SDLC — ver `specs/README.md`)

Workers del flujo Spec-Driven Development. Los invocan los comandos `/spec`, `/plan`, `/tasks`, `/analyze`, `/verify` y `/contract` (la interfaz interactiva vive en el hilo principal; el agente hace el trabajo pesado y autónomo). Una etapa puede tener **más de un agente** cuando separa redacción de su V&V (ver Requisitos abajo). Cada agente **encarna un rol profesional** acorde a su etapa.

| Agente | Rol profesional | Etapa / fase | Invocado por |
|---|---|---|---|
| `requirements-analyst` | Analista de Requerimientos | Requisitos — Fase 0 + redacta spec | `/spec` |
| `requirements-reviewer` | QA de requisitos (read-only) | Requisitos — V&V / test de ambigüedad | `/spec` (tras la redacción) |
| `solution-designer` | Arquitecto de Software | Diseño — `plan.md` y/o `contract.md` | `/plan`, `/contract` (OPCIONAL) |
| `spec-analyst` | QA de la especificación (read-only) | Análisis — consistencia antes de codear | `/analyze` |
| `builder` | Ingeniero de Software sénior | Construcción — implementa + tests | hilo principal (tareas acotadas) |
| `validator` | Ingeniero de V&V | Test y validación — Definition of Done con evidencia | `/verify` |
| `e2e-tester` | Ingeniero de QA end-to-end | Test y validación — interfaz real corriendo — **OPCIONAL** | `/verify` |

- `requirements-analyst.md` — **Requerimiento (redacta)**. Rol: Analista de Requerimientos. Investiga/des-ambigua el pedido (Fase 0) y redacta/refina `spec.md` + criterios de aceptación testeables; explora para no duplicar; devuelve los `[VERIFICAR]`. (Invocado por `/spec`.)
- `requirements-reviewer.md` — **Requerimiento (V&V de requisitos / test de ambigüedad)**. Rol: Analista de Requerimientos sénior en rol de revisor / QA de requisitos. **Read-only**: NO redacta ni aprueba la spec — la **audita de forma adversarial** (ambigüedad, supuestos ocultos, criterios no testeables, casos faltantes) y reporta defectos con ubicación y reescritura/pregunta sugerida, atajando el defecto antes de que llegue al código. (Invocado por `/spec`, tras la redacción.)
- `solution-designer.md` — **Diseño**. Produce `contract.md` (la interfaz que otros consumen) y/o `plan.md` (enfoque interno, reuso). (Invocado por `/plan` y `/contract`.)
- `spec-analyst.md` — **Análisis**. Chequeo de consistencia read-only spec↔contract↔plan↔tasks↔contratos-del-repo. (Invocado por `/analyze`.)
- `validator.md` — **Test y validación**. Recorre cada AC contra código + tests, devuelve tabla AC×evidencia×veredicto; marca qué ACs requieren prueba end-to-end. (Invocado por `/verify`.)
- `builder.md` — **Construcción**. Implementa una tarea/slice siguiendo los patrones del repo + tests; compila y corre los tests acotados. (Invocado por el hilo principal en tareas acotadas.)
- `e2e-tester.md` — **QA end-to-end** _(OPCIONAL)_. Ejercita el sistema corriendo de verdad (levanta el proceso, prepara estado, ejecuta escenarios golden/edge/auth contra la interfaz real) y deja un log persistente. Sólo aplica si tu proyecto expone una interfaz que se puede ejercitar de punta a punta (API, CLI, servicio); si no, borralo.

#### Mapa etapa → agente

| Etapa SDLC | Agente(s) | Comando |
|---|---|---|
| **Requisitos** | `requirements-analyst` (redacta) **+** `requirements-reviewer` (V&V de requisitos) | `/spec` |
| **Diseño** | `solution-designer` | `/plan`, `/contract` (OPCIONAL) |
| **Análisis** | `spec-analyst` | `/analyze` |
| **Construcción** | `builder` | hilo principal (tareas acotadas) |
| **Test y validación** | `validator` (+ `e2e-tester`, OPCIONAL) | `/verify` |

La etapa **Requisitos** es la única con dos agentes: separa la **redacción** (`requirements-analyst`) de su **V&V** (`requirements-reviewer`), para atajar defectos de requisitos lo más a la izquierda posible. El reviewer es read-only y solo reporta; el autor y el ingeniero humano resuelven.

## Roadmap

- Extendé con agentes propios a medida que aparezcan tareas multi-paso, autónomas y de salida larga (ej. un agente que itere sobre un reporte de mutation testing hasta resolver survivors, o un checklist de migración que crezca más allá de una skill).
