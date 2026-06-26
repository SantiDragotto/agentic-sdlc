# CLAUDE.md

Reglas de comportamiento específicas de Claude para este repo. Los **hechos** agnósticos de herramienta (comandos, layout de carpetas, contratos del repo, arquitectura, claves de configuración) viven en **`AGENTS.md`** — esa es la autoridad técnica. Este archivo no los redefine: amplifica las **consecuencias de comportamiento** para el desarrollo asistido por Claude.

## Quick Reference

Para los ítems de abajo, ver **`AGENTS.md`**:

- `## Commands` — `{{BUILD_COMMAND}}`, `{{TEST_COMMAND}}`, `{{RUN_COMMAND}}`, `{{MIGRATION_COMMAND}}`
- `## Configuration` — claves de config / `{{SECRETS_FILE}}`
- `## Architecture` — layout del código, patrón en capas, cross-cutting concerns
- `## Repo Contracts` — invariantes de ID, target framework, secretos, autorización, estándares de testing
- `## Testing` — base de tests, helpers de auth/fixtures

## Behavioral Rules

### Modo de trabajo por defecto: SDD-first (gate de entrada)

Es el **default de entrada** que se evalúa **antes** que el resto de las reglas de esta sección. Ante CUALQUIER prompt, primero **entendé la intención del dev** (qué quiere lograr y por qué, no la solución literal que tipeó) e **investigá / des-ambiguá el pedido** (Fase 0): explorá lo que ya existe, listá supuestos y ambigüedades y resolvelos con el humano antes de clasificar. Recién con eso claro, clasificás y ruteás. No arranques a codear una feature sin pasar por este gate.

**Triage — clasificá el pedido y elegí ruta** (la lista canónica de señales que disparan SDD vive en `specs/CONSTITUTION.md §1`; acá ruteás, no la re-enumerás):

1. **Feature / cambio observable** (dispara ≥1 señal de `CONSTITUTION.md §1`: interfaz pública/contrato, campo nuevo, autorización, invariante de persistencia, cambio de comportamiento que un usuario o consumidor nota) → **flujo SDD**. Entrá en la fase que corresponda según lo que ya exista: sin spec → `/spec` (y `/contract` si tu proyecto expone una interfaz que otros consumen — OPCIONAL); `spec.md` `approved` sin plan → `/plan`; plan aprobado → `/tasks` → `/analyze` → implementar → `/verify`. La mecánica de fases y agentes está en `## Spec-Driven Development (SDD)` abajo y en `specs/README.md`.
2. **Fix trivial / mecánico** (catálogo canónico de qué cuenta como trivial: `CONSTITUTION.md §1`) → permitido **directo, sin spec**. Ruta rápida salta `spec`/`plan`/`tasks`, **no** los repo contracts: si toca lógica observable, autorización o persistencia, el test sigue siendo obligatorio (`## Testing Standards`). **Antes de aplicar, chequeá impacto** (grepeá `specs/`): si toca un `contract.md` `shipped` (OPCIONAL) o un criterio de aceptación de una spec existente, deja de ser ruta rápida → es cambio de contrato (ajustalo y avisá a los consumidores; ver `CONSTITUTION.md §1`).
3. **Pregunta / exploración / auditoría** (incl. `/bug-finder`) → respondé; **no** produce spec ni código. Si la exploración revela trabajo de feature, **frená y PROPONÉ abrir una spec** antes de codear — no lo hagas ad-hoc.
4. **Ops / infra** (config, tooling, CI, scripts) → fuera del SDD, salvo que cambie comportamiento observable del producto → entonces es feature (caso 1).

**Override del dev:** una instrucción explícita de saltarse el SDD ("hacelo directo", "spike", "prototipo", "sin spec") **gana**. Confirmás el trade-off en una línea (queda sin spec/criterios de aceptación) y procedés; si era una feature real, ofrecé escribir la spec *después*. Para un **hotfix urgente**: implementás el fix con sus tests obligatorios y registrás la spec a posteriori antes de cerrar con `/verify`. El gate es el default, no una jaula.

**Postura:** quedate dentro del framework. Si te encontrás haciendo trabajo de feature ad-hoc (un MD suelto en `docs/`, código sin spec), frená y ruteá por SDD. **Una feature = un `NNN`**; si un pedido junta varias features, cortalo en specs separadas (un `NNN` c/u) y preguntá el corte. Ante duda de **clasificación**, el default conservador es SDD (no frenes para confirmar cada ruteo menor); ante duda de **contrato/comportamiento**, eso sí va como `[VERIFICAR]` y bloquea avanzar. Y **mantené la simplicidad**: proponé la solución más simple que cumple los criterios; toda complejidad/abstracción/dependencia nueva se justifica o no entra, y nada especulativo (`CONSTITUTION.md §3`).

**Preguntar en cada fase (no-negociable):** corré el protocolo `clarify` en spec/plan/tasks/construcción/verify; ninguna suposición material es silenciosa (ver `CONSTITUTION.md §1`).

**Siempre activo + cierre proactivo:** el framework no se invoca — el dev **no** tiene que decirte "usá SDD" ni nombrarte qué spec ajustar; asumilo en cada sesión. Y **al cerrar cualquier trabajo, reconciliá por tu cuenta** los specs/contracts que tocaste (criterios de aceptación, `/verify`, `contract.md` `status` si aplica, `INDEX.md`, avisos a consumidores); identificás **vos** qué afecta (grepeá `specs/`), no esperás que te lo pidan.

### Roles de los agentes (cada uno encarna su oficio)

Cada agente del flujo actúa con el **rol profesional** que corresponde a su etapa — su system prompt lo declara en la primera línea. La IA **produce** en cada paso; el **ingeniero humano decide** en cada compuerta (V&V de fase).

- `requirements-analyst` → **Analista de Requerimientos** (Fase 0 des-ambiguación + redacción de la spec).
- `requirements-reviewer` → **QA de requisitos** (test de ambigüedad — V&V de la fase Requisitos; el autor no se valida a sí mismo).
- `solution-designer` → **Arquitecto de Software** (plan / contrato).
- `spec-analyst` → **QA de la especificación** (consistencia entre artefactos).
- `builder` → **Ingeniero de Software sénior** (arquitectura + código + tests).
- `validator` → **Ingeniero de V&V** (Definition of Done con evidencia).
- `e2e-tester` → **Ingeniero de QA end-to-end** (OPCIONAL).

**V&V en cada fase, no solo al final:** cada fase tiene **criterios de salida** al pie de su artefacto que el humano valida antes de avanzar (ver `specs/README.md`). Un defecto se ataja en su fase, no en `/verify`.

### Convenciones del proyecto (completar)

Reemplazá estos bullets por las convenciones duras de tu código (cómo se registran dependencias, cómo se accede a la persistencia, qué base/abstracción extender en vez de reimplementar, cómo fluyen los errores). Mantenelos como reglas accionables, no como prosa genérica.

- [EJEMPLO — reemplazar] **Hay un único camino para registrar/cablear componentes.** Seguilo en vez de cablear a mano; nombrá las clases según la convención que el descubrimiento automático espera.
- [EJEMPLO — reemplazar] **No accedas a la capa de datos cruda directamente.** Pasá por la abstracción del repo (unit-of-work / repositorio / cliente) que ya existe.
- [EJEMPLO — reemplazar] **Extendé la base existente en vez de reimplementar el camino común** (CRUD, handler, comando). Usá los hooks de extensión para el comportamiento específico.
- [EJEMPLO — reemplazar] **Reutilizá middleware/helpers existentes aunque sus deps sean incómodas.** Antes de escribir una versión "mínima" para tests o un flujo nuevo, grepeá por uno existente y stubeá sus deps — clonar la lógica genera drift silencioso cuando la versión de producción evoluciona y el duplicado no.

### Contratos duros del repo (ejemplos — reemplazar)

Estas son reglas no-negociables del repo que se asumen en cada fase del SDD. La autoridad técnica vive en `AGENTS.md`; acá amplificás la consecuencia para Claude. Reemplazá cada bloque por el contrato real de tu proyecto (o borralo si no aplica).

#### Invariantes de ID (ejemplo — reemplazar)

[EJEMPLO — reemplazar] Cuando implementes un camino de creación/actualización de entidades:

- **Create:** el `Id` del body se ignora; el backend lo genera. Los tests deben afirmar que el `Id` de la respuesta **no** es igual al enviado.
- **Update:** el `Id` de la ruta/persistido gana sin importar lo que diga el body. Los tests deben afirmar que un `Id` divergente en el body no se propaga.

#### Autorización (ejemplo — reemplazar)

[EJEMPLO — reemplazar] Cuando agregues un endpoint/operación protegida:

1. Aplicá el mecanismo de autorización del repo (policy/decorator/middleware) — no inventes uno inline.
2. Declará el permiso requerido con la convención del proyecto (`recurso.nivel`).
3. Respetá la jerarquía de niveles (ej. `write` satisface `write` y `read`; `read` solo `read`).
4. Un claim/credencial del tipo equivocado **debe** rechazarse — no aflojes esto.
5. El rol/bypass de superusuario, si existe, debe cubrirse explícitamente en tests.

Requisitos nuevos de auth cross-cutting van como un handler en la cadena, nunca como lógica inline en el controlador.

#### Target framework / compatibilidad (ejemplo — reemplazar)

[EJEMPLO — reemplazar] Si el código apunta a múltiples versiones de runtime/lenguaje, antes de introducir una API nueva verificá que exista en todas las versiones soportadas; si no, guardala con un fallback. No asumas que la última feature del lenguaje está disponible en todos los targets.

#### Secretos y config local (ejemplo — reemplazar)

[EJEMPLO — reemplazar] Sobre `{{SECRETS_FILE}}`:

- **Nunca** lo modifiques.
- **Nunca** reveles sus valores en chat, mensajes de commit, logs, corridas de test, descripciones de PR ni memoria.
- Referite a la config solo por nombre de clave.
- Si necesitás un valor para una tarea, pedíselo al usuario inline.

#### Migraciones / cambios de esquema (ejemplo — reemplazar)

[EJEMPLO — reemplazar] Si el proyecto tiene migraciones de esquema/datos vía `{{MIGRATION_COMMAND}}`:

- **Nunca** corras `{{MIGRATION_COMMAND}}` por tu cuenta. Dejá la corrida real al desarrollador salvo que lo pida explícitamente.
- **Nunca** escribas archivos de migración a mano si la herramienta los genera.
- Al proponer una migración, sugerí el comando con la convención de nombres correcta y frená — que lo corra el usuario.

## Testing Standards (Mandatory)

- Todo **cambio de comportamiento** (lógica observable, autorización, persistencia) **DEBE** incluir o actualizar tests. Esta es una meta-regla, no negociable.
- Convención de naming consistente para tests, p. ej. `Metodo_ComportamientoEsperado_CuandoCondicion` (adaptá a tu framework/idioma).
- **Definí tus matrices de test obligatorias.** Para cada categoría de cambio recurrente en tu proyecto (autorización, CRUD/persistencia, validación, mapeo error→código), enumerá los escenarios mínimos que un cambio de esa categoría DEBE cubrir, y exigilos. Sin esa matriz, "tiene tests" es ambiguo.
  - [EJEMPLO — reemplazar] Para un endpoint protegido: credencial válida → éxito; sin permiso → denegado; tipo de claim equivocado → denegado; permiso distinto → denegado; bypass de superusuario → éxito.
  - [EJEMPLO — reemplazar] Para una entidad con CRUD: create ignora el ID entrante; update preserva el ID persistido; not-found en get/update/delete; hooks de extensión invocados.

### Ante un test que falla — diagnosticá antes de tocar

Un test que falla es **dato, no ruido**. Nunca ajustes un test solo para ponerlo en verde. Clasificá la causa primero:

1. **El test captura correctamente una violación real de lógica de negocio** → arreglá la implementación, dejá el test como está.
2. **La implementación cambió a propósito y el test codifica el comportamiento viejo** → actualizá el test para afirmar el contrato nuevo; confirmá que el cambio fue deliberado (mensaje de commit, discusión de diseño reciente, instrucción explícita del usuario) antes de asumirlo.
3. **El test mismo tiene un bug** (literal hardcodeado que debería referenciar una constante, fixture obsoleta, typo, header equivocado, etc.) → arreglá el test.

Cuando la causa es ambigua (p. ej. una regla de auth relajada en un commit vago de "ajuste"), surfaceála al usuario con el trade-off en vez de adivinar.

## Spec-Driven Development (SDD)

Toda **feature** nueva (no fixes triviales) pasa por el flujo SDD: la spec versionada en `specs/` es la fuente de verdad, no el prompt. Proceso y reglas en `specs/README.md` + `specs/CONSTITUTION.md`; onboarding en `specs/GUIA-EQUIPO-SDD.md`.

Esta sección es la **mecánica del flujo** (qué hace cada fase). El **gate de entrada** que decide cuándo aplica (feature vs. fix trivial vs. exploración vs. ops, y en qué fase entrar) vive en `### Modo de trabajo por defecto: SDD-first` arriba; la lista canónica de señales de triage, en `specs/CONSTITUTION.md §1`.

- **Un comando por fase** (interfaz interactiva) que delega en **un agente por etapa del flujo**: `/spec` → `requirements-analyst` (Fase 0 + redacción) + `requirements-reviewer` (V&V de requisitos / test de ambigüedad); `/plan` (y `/contract`, OPCIONAL) → `solution-designer`; `/analyze` → `spec-analyst`; `/verify` → `validator` (+ `e2e-tester`, opcional); construcción/implementación → `builder`. `/tasks` corre en el **hilo principal** (sin agente dedicado).
- **OPCIONAL — fase contrato:** si tu proyecto expone una interfaz que otros consumen (API, librería, CLI, schema/formato), el back/dueño produce el `contract.md` (interfaz/DTOs/auth/estados) en `specs/NNN-*/` con lifecycle `proposed`→`approved`→`shipped`. Si tu proyecto no expone una interfaz pública, ignorá `/contract`, `contract.md` y `e2e-tester` (ver `GETTING-STARTED.md` para borrarlos).
- **Nada es "done" sin `/verify`** (cada criterio de aceptación con evidencia). Al cerrar: `INDEX.md` actualizado, y `contract.md`→`shipped` si aplica.
- Las **reglas duras del repo** (IDs, auth, persistencia, migraciones, secretos, tests) **se asumen** en cada fase — no se re-declaran en cada spec; la autoridad sigue siendo este archivo + `AGENTS.md`.

## Tooling Index

Herramientas disponibles en este repo. Preferí invocarlas antes que reproducir su workflow inline.

| Type | Name | Status | When to use |
|---|---|---|---|
| command | `/spec` `/plan` `/tasks` `/analyze` `/verify` `/contract` | Active | Flujo SDD por fases (ver `specs/README.md`). Interfaz interactiva que delega en los agentes SDD. Usar al construir cualquier feature nueva. `/contract` es OPCIONAL (solo si tu proyecto expone una interfaz que otros consumen). |
| agent | `requirements-analyst` | Active | Etapa Requerimiento del SDD: Fase 0 (investiga/des-ambigua el pedido) + redacta `spec.md` + criterios de aceptación, explora para no duplicar. Invocado por `/spec`. |
| agent | `requirements-reviewer` | Active | V&V de la fase Requisitos: **test de ambigüedad**. Audita la `spec.md` (ambigüedad, supuestos ocultos, criterios no testeables, casos faltantes) read-only antes de aprobar; el autor no se valida a sí mismo. Invocado por `/spec`. |
| agent | `solution-designer` | Active | Etapa Diseño: produce `plan.md` (enfoque, reuso) y/o `contract.md` (la interfaz, OPCIONAL). Invocado por `/plan` y `/contract`. |
| agent | `spec-analyst` | Active | Etapa Análisis: chequeo de consistencia read-only spec↔contract↔plan↔tasks↔repo-contracts. Invocado por `/analyze`. |
| agent | `builder` | Active | Etapa Construcción: implementa una tarea/slice siguiendo los patrones del repo + tests; compila y corre la suite. |
| agent | `validator` | Active | Etapa Test y validación (Definition of Done): recorre cada criterio de aceptación contra código + tests, devuelve evidencia. Invocado por `/verify`. |
| agent | `e2e-tester` | Active (OPCIONAL) | Valida lógica end-to-end contra la interfaz pública corriendo (API/CLI/etc.). Solo si tu proyecto expone una interfaz que otros consumen. Loguea cada escenario bajo el directorio configurado (`{{LOG_DIR}}`, ej. `.claude/agents/e2e-tester/test-runs/`). |
| skill | `/bug-finder` | Active | Auditoría iterativa exhaustiva del código trabajado. Ciclos de revisión hasta convergencia (2 loops limpios consecutivos, máx 8). Invocar con `/bug-finder`, "revisá el código", "buscá bugs". |
| skill | `/validate-specs` | Active | Gate **determinístico** del proceso SDD: corre `validate-sdd.{ps1,sh}` y falla si una spec avanzó de fase con `[VERIFICAR]` abiertos, sin `approved-by:`, o con criterios sin tildar; chequea cross-refs y fila en INDEX. Corre en CI (`.github/workflows/sdd-validation.yml`). Invocar antes de aprobar/cerrar una spec o con "validá las specs". |
| skill | `/setup` | Active | Onboarding **guiado**: entrevista por categorías (stack, comandos, arquitectura, repo contracts, testing, secretos) y llena los 3 archivos obligatorios (`AGENTS.md`, `CONSTITUTION.md §4`, convenciones de `CLAUDE.md`) confirmando cada bloque con el humano. Alternativa guiada al llenado manual de `GETTING-STARTED.md`. No escribe código. |
| skill | `/clarify` | Active | Protocolo de preguntas que se corre en CADA fase (spec, plan, tasks, construcción, verify) para que la IA no asuma en silencio: surface como preguntas todo lo que asumiría, agrupado por categoría y con un default sugerido; el dev contesta, elige, o delega. Delegado → `[IA-DECIDIÓ]` (registrado, no bloquea); sin resolver → `[VERIFICAR]` (bloquea `approved`). Lo invocan los comandos y los agentes. |
| hook | `block-forbidden-command` | Active | `PreToolUse` Bash — bloquea un comando prohibido (ej. `{{MIGRATION_COMMAND}}`). Defensa en profundidad del repo contract de migraciones. Implementación: `.claude/hooks/block-forbidden-command.{ps1,sh}`. |
| hook | `block-protected-file` | Active | `PreToolUse` Edit/Write — bloquea modificaciones a un archivo protegido (ej. `{{SECRETS_FILE}}`). Defensa en profundidad del repo contract de secretos. Implementación: `.claude/hooks/block-protected-file.{ps1,sh}`. |

Las convenciones y el cómo-agregar-cada-tipo viven en `.claude/{agents,skills,commands,hooks,rules}/README.md`.

## Working Preferences

- **No releas archivos** ya leídos en esta sesión salvo que el usuario lo pida. Minimizá tool calls y trabajá con lo que está en contexto.
- **Mantené el foco en el scope que el dev pidió.** No agregues tests ni cambios fuera de ese scope salvo que se pida explícitamente.
