# agentic-sdlc

## Empezá acá → [`GETTING-STARTED.md`](./GETTING-STARTED.md)

Antes de tocar nada, leé `GETTING-STARTED.md`: te dice qué tres archivos rellenar, cómo barrer los placeholders y cómo hacer tu primera feature de punta a punta. El resto de este README es el mapa del kit.

---

**agentic-sdlc** es un template agnóstico de lenguaje y **sin código** para arrancar un proyecto nuevo —de cualquier tipo: API, librería, CLI, app, servicio, lo que sea— y empezar a trabajar con Claude/IA desde el día uno bajo un flujo de **Spec-Driven Development (SDD)**. No trae stack, ni framework, ni build: trae la **maquinaria de proceso** (comandos, agentes, hooks, plantillas de spec y reglas de gobernanza) ya cableada, con marcadores `{{TOKEN}}` y bloques `[EJEMPLO — reemplazar]` para que la adaptes a tu proyecto en una tarde.

---

## Qué significa SDLC — y por qué se llama así

**SDLC = Software Development Life Cycle** — el *ciclo de vida del desarrollo de software*: la secuencia de fases por las que pasa **todo** cambio de software, desde entender el problema hasta entregar algo que funciona y está verificado. No es un invento de este kit ni de la IA — es la forma clásica de ordenar la ingeniería de software:

> **requisitos → análisis → diseño → construcción → pruebas (V&V) → entrega**

Lo **"agentic"** del nombre es *cómo* se recorre ese ciclo acá: cada fase la **ejecuta un agente de IA que encarna un rol profesional** (analista de requerimientos, arquitecto, ingeniero, QA, V&V) y en **cada compuerta entre fases decide un ingeniero humano**. La regla que gobierna todo el kit:

> **La IA produce en cada paso; el humano valida y decide el pasaje en cada compuerta.**

Es decir: *agentic-sdlc* = el ciclo de vida de software de siempre, recorrido por agentes y con el humano como dueño de cada decisión. **SDD (Spec-Driven Development)** es la metodología concreta con la que este kit recorre ese ciclo.

---

El **pitch de SDD** en un párrafo: la **spec versionada en el repo es la fuente de verdad, no el prompt**. El prompt es efímero y se pierde; la spec queda en git, se revisa y se verifica. Cada **feature = una carpeta numerada** (`specs/NNN-slug/`) con su `spec.md` (comportamiento + **criterios de aceptación** verificables, true/false), su `plan.md` (el cómo) y su `tasks.md` (la checklist atómica). Y **nada está `done` hasta pasar `/verify`**, recorriendo cada criterio de aceptación uno por uno con **evidencia** (`archivo:línea` y/o comportamiento ejecutado real). Esto reemplaza el "escribo lo que quiero en un prompt y lo voy refinando": acá el detalle vive en un artefacto que se versiona, se discute y se cierra.

---

## El ciclo de vida, mapeado al kit

Cada fase clásica del SDLC tiene en este kit un **artefacto**, un **comando** y un **agente con su rol**. Lo que cada fase *busca* es lo que la justifica — no es burocracia, es atajar el defecto donde corregirlo es barato:

| Fase del SDLC | Qué busca | En el kit (artefacto · comando · agente) |
|---|---|---|
| **Intake / triage** | decidir si esto es una feature (→ SDD) o un fix trivial (→ ruta rápida) | gate de `CLAUDE.md` — sin artefacto |
| **Requisitos** | entender *qué* y *por qué*; criterios **verificables**, no objetivos vagos | `spec.md` · `/spec` · `requirements-analyst` + `requirements-reviewer` |
| **Análisis** | descomponer el problema y chequear consistencia antes de codear | `spec.md §3` + reporte de `/analyze` · `spec-analyst` |
| **Diseño** | *cómo* se construye, qué se **reutiliza**, y la interfaz expuesta | `plan.md` · `/plan` · `solution-designer` (+ `contract.md` · `/contract`, OPCIONAL) |
| **Construcción** | escribir el código y sus **tests obligatorios** | `tasks.md` · `/tasks` + `builder` |
| **Pruebas / V&V** | probar que **cada criterio de aceptación** se cumple, con evidencia | `/verify` · `validator` (+ `e2e-tester`, OPCIONAL) |
| **Entrega / cierre** | marcar `done`, actualizar `INDEX.md`, pasar el contrato a `shipped` | cierre de `/verify` |

> El detalle fase por fase (estados del lifecycle, criterios de salida, quién aprueba) vive en [`specs/README.md`](./specs/README.md) — incluida la misma tabla con la columna *Etapa SDLC*. Acá te quedás con el mapa conceptual.

---

## La teoría: cazar el defecto lo más a la izquierda posible (*shift-left*)

El principio que ordena todo el flujo: **un mismo defecto cuesta más cuanto más tarde se lo atrapa.** Una ambigüedad de requisitos que llega a producción obliga a rehacer diseño, código y tests —y a arreglar lo que ya rompió—; esa misma ambigüedad resuelta mientras se escribe la spec se corrige moviendo una línea de texto. De ahí **shift-left**: correr la verificación hacia la **izquierda** del ciclo, lo más cerca posible del origen del error.

```
Costo relativo de corregir un mismo defecto, según dónde se lo atrapa
(ilustrativo — la cifra exacta varía entre estudios; el orden de magnitud, no):

  Requisitos  →   Diseño   →  Construcción  →  /verify  →  Producción
     1x             ~5x          ~10x           ~25x         100x+
  └─── izquierda: barato ───────────────────────── derecha: caro ───┘
```

Por eso el kit **no deja la verificación para el final**: cada fase tiene su propia V&V —sus **criterios de salida**— que el humano valida antes de avanzar. Es el **modelo en V**: a cada fase de la izquierda (requisitos, diseño, construcción) le corresponde una validación. Los mecanismos que empujan el control a la izquierda:

- **Fase 0 — des-ambiguación.** Antes de escribir una línea, el `requirements-analyst` reconstruye la intención real y resuelve ambigüedades con el humano. El defecto más barato de atajar.
- **Protocolo `clarify` en cada fase.** Ninguna suposición material es silenciosa: lo que la IA asumiría se convierte en pregunta *antes* de avanzar.
- **Test de ambigüedad (`requirements-reviewer`).** La V&V de la fase de requisitos: el autor de la spec no se valida a sí mismo.
- **`/analyze` antes de codear.** Caza inconsistencias spec ↔ plan ↔ tasks cuando corregir todavía es barato (editar un MD, no refactorizar código en producción).
- **Tests obligatorios** en construcción y **`/verify`** como compuerta **final** de Definition of Done — no como la *única* compuerta.

> En una frase: cada `/comando` del flujo es una red de seguridad puesta lo más a la izquierda posible. El objetivo no es producir documentos — es **que el error aparezca en la fase donde corregirlo cuesta menos.**

---

## El flujo en un vistazo

Todo pedido pasa por un **triage**: un fix trivial va por la ruta rápida (con sus tests); una feature recorre las fases SDD. En **cada** paso corre `clarify` (la IA pregunta antes de asumir) y se chequean los criterios de salida (V&V).

```mermaid
flowchart TD
    idea([Pedido del dev]) --> triage{Triage}
    triage -->|fix trivial| fast[Ruta rapida + tests]
    triage -->|feature| spec["/spec : spec.md"]
    spec --> plan["/plan : plan.md"]
    plan --> tasks["/tasks : tasks.md"]
    tasks --> analyze["/analyze"]
    analyze --> build["construir : builder"]
    build --> verify["/verify"]
    verify --> done([done])
    ask[["En cada paso: clarify (preguntas) + criterios de salida (V y V)"]] -.-> spec
    ask -.-> plan
    ask -.-> tasks
    ask -.-> build
    ask -.-> verify
```

---

## Qué hay en el kit

La **maquinaria de IA** vive en `.claude/` (detalle en [`.claude/README.md`](./.claude/README.md)). Resumen:

| Tipo | Cuenta | Qué es |
|---|---|---|
| **Comandos** (`.claude/commands/`) | 6 | Un comando fino por fase del flujo (`/spec` `/plan` `/tasks` `/analyze` `/verify` `/contract`); cada uno delega en un agente. `/contract` es OPCIONAL. |
| **Agentes** (`.claude/agents/`) | 7 | Subagentes con rol profesional (analista, arquitecto, QA, ingeniero, V&V…) que ejecutan cada etapa con contexto aislado. |
| **Skills** (`.claude/skills/`) | 4 | Workflows estructurados: `bug-finder`, `validate-specs` (gate determinístico + CI), `setup` (onboarding), `clarify` (preguntas por fase). |
| **Hooks** (`.claude/hooks/`) | 2 | Guardas determinísticas que el harness corre en eventos: `block-forbidden-command` y `block-protected-file` (cada uno `.ps1` + `.sh`). |

---

## Este proyecto usa SDD

> **Si sos un asistente de IA (o una persona) que va a trabajar en un repo armado con este kit, leé en este orden:**
>
> 1. **`CLAUDE.md`** — el gate de comportamiento: clasifica cada pedido y decide si va por SDD o por ruta rápida.
> 2. **`AGENTS.md`** — los hechos técnicos del repo: stack, comandos, arquitectura, repo contracts.
> 3. **`specs/README.md`** — el proceso SDD canónico, fase por fase.
>
> Ante conflicto: en cuestiones de **proceso** gana `specs/README.md`; en cuestiones **técnicas** gana `AGENTS.md`; siempre gana la regla **más restrictiva** y, si persiste, se pregunta.

---

## Mapa de archivos del kit

```
agentic-sdlc/
├── README.md                 ← este archivo (landing del kit)
├── GETTING-STARTED.md        ← cómo adoptar el template — EMPEZÁ ACÁ
├── CLAUDE.md                 ← gate de COMPORTAMIENTO para Claude (triage SDD-first)
├── AGENTS.md                 ← HECHOS agnósticos de herramienta (stack, comandos, arquitectura, contratos) — autoridad técnica
├── .gitignore                ← ignora settings locales y basura de OS/editor
│
├── .claude/                  ← maquinaria de Claude Code (comandos, agentes, hooks…)
│   ├── settings.json         ← config committeada: registra los hooks (elegí runner PowerShell o POSIX)
│   ├── commands/             ← un comando fino por fase del flujo
│   │   ├── spec.md           ← /spec      → requirements-analyst + requirements-reviewer
│   │   ├── plan.md           ← /plan      → delega en solution-designer
│   │   ├── tasks.md          ← /tasks     → corre en el hilo principal (sin agente)
│   │   ├── analyze.md        ← /analyze   → delega en spec-analyst
│   │   ├── verify.md         ← /verify    → delega en validator (+ e2e-tester opcional)
│   │   ├── contract.md       ← /contract  → delega en solution-designer  (OPCIONAL)
│   │   └── README.md
│   ├── agents/               ← subagentes especializados (system-prompts)
│   │   ├── requirements-analyst.md   ← escribe la spec, exprime los [VERIFICAR]
│   │   ├── requirements-reviewer.md  ← V&V de requisitos / test de ambigüedad (read-only)
│   │   ├── solution-designer.md      ← diseña plan y contrato
│   │   ├── spec-analyst.md           ← chequea consistencia spec↔plan↔tasks
│   │   ├── validator.md              ← corre /verify contra cada criterio
│   │   ├── builder.md                ← implementa las tareas
│   │   ├── e2e-tester.md             ← valida end-to-end real   (OPCIONAL)
│   │   └── README.md
│   ├── skills/               ← skills reutilizables (workflows estructurados)
│   │   ├── bug-finder/SKILL.md       ← loop de búsqueda/convergencia de bugs
│   │   ├── validate-specs/SKILL.md   ← gate determinístico del proceso (+ scripts + CI)
│   │   ├── setup/SKILL.md            ← onboarding guiado (llena los 3 archivos obligatorios)
│   │   ├── clarify/SKILL.md          ← protocolo de preguntas en CADA fase
│   │   └── README.md
│   ├── rules/                ← reglas auxiliares enganchables
│   │   └── README.md
│   └── hooks/                ← scripts determinísticos que el harness corre en eventos
│       ├── block-forbidden-command.{ps1,sh}  ← bloquea un comando Bash prohibido (ej. {{MIGRATION_COMMAND}})
│       ├── block-protected-file.{ps1,sh}     ← bloquea Edit/Write a un archivo protegido (ej. {{SECRETS_FILE}})
│       └── README.md
│
└── specs/                    ← gobernanza y carpetas de features
    ├── README.md             ← PROCESO SDD canónico (gana ante conflicto de proceso)
    ├── CONSTITUTION.md       ← reglas no-negociables del proceso (§1 triage, §4 tus contratos duros)
    ├── GUIA-EQUIPO-SDD.md    ← instructivo paso a paso para el equipo
    ├── INDEX.md              ← catálogo de specs del repo y su estado
    ├── HALLAZGOS.md          ← inbox de bugs/dudas encontrados usando la app
    ├── TEMPLATE/             ← plantillas en blanco para copiar a cada feature
    │   ├── spec.md · plan.md · tasks.md
    │   └── contract.md       ← OPCIONAL — solo si exponés una interfaz
    └── 000-EXAMPLE-feature/  ← ejemplo lleno READ-ONLY (borralo cuando entiendas el flujo)
        └── spec.md · plan.md · tasks.md · contract.md
```

---

## Los comandos del flujo

Cada fase tiene un comando fino que delega en un agente especializado:

| Fase | Comando | Agente | Qué produce |
|---|---|---|---|
| Contrato *(OPCIONAL)* | `/contract` | `solution-designer` | `contract.md` — la forma de tu interfaz |
| Spec | `/spec` | `requirements-analyst` + `requirements-reviewer` | `spec.md` — el qué y el por qué + criterios de aceptación (con test de ambigüedad) |
| Plan | `/plan` | `solution-designer` | `plan.md` — el cómo, qué se reutiliza, riesgos |
| Tasks | `/tasks` | — (hilo principal) | `tasks.md` — checklist atómica atada a los criterios |
| Analyze | `/analyze` | `spec-analyst` | reporte de consistencia (antes de codear) |
| Verify | `/verify` | `validator` (+ `e2e-tester`) | cada criterio en ✅ con evidencia → `done` |

> Las fases marcadas **OPCIONAL** (`/contract`, `contract.md`, agente `e2e-tester`) solo aplican si tu proyecto expone una interfaz que otros consumen (API, librería, CLI, schema/formato). Si no, `GETTING-STARTED.md` te dice cómo borrarlas.

---

## Convenciones de placeholders (resumen)

| Marcador | Qué significa | Qué hacés |
|---|---|---|
| `{{TOKEN}}` | un valor que DEBÉS reemplazar (`{{PROYECTO}}`, `{{BUILD_COMMAND}}`, `{{TEST_COMMAND}}`, `{{RUN_COMMAND}}`, `{{SOURCE_ROOT}}`, `{{SECRETS_FILE}}`, `{{MIGRATION_COMMAND}}`) | buscar y reemplazar por el real |
| `[EJEMPLO — reemplazar]` | bloque ilustrativo que muestra la FORMA | editar o borrar |
| `[VERIFICAR]` | pregunta abierta que **bloquea** pasar a `approved` | resolver antes de aprobar la spec |

El detalle de cómo barrerlos está en `GETTING-STARTED.md`.

---

El kit está escrito en **español (rioplatense)** para toda la prosa humana; las keys de YAML, los enums de estado (`draft`/`approved`/`proposed`/`shipped`/`done`), la config y la jerga SDD van en inglés. Un equipo que prefiera trabajar en inglés puede traducir la prosa: la estructura es independiente del idioma.
