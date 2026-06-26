# AGENTS.md

> Los **hechos técnicos agnósticos de herramienta** sobre los que opera *cualquier* asistente de IA en este repo (Claude, Cursor, Aider, Codex, Warp, etc.). Este archivo es la **autoridad técnica**: stack, comandos, arquitectura y los contratos no-negociables del repo. No describe comportamiento de un asistente puntual — eso vive en `CLAUDE.md`. Ante conflicto de proceso gana `specs/README.md`.
>
> **Cómo usar este template:** cada sección trae placeholders `{{TOKEN}}` que **debés** reemplazar y bloques `[EJEMPLO — reemplazar]` que ilustran la FORMA esperada y editás o borrás. Completá todo lo marcado antes de tratar este archivo como fuente de verdad.

## Project Overview

> Completar: qué es `{{PROYECTO}}` en una o dos frases. Qué problema resuelve y para quién. Si expone una interfaz que otros consumen (API, librería, CLI, schema/formato), decilo acá.

`{{PROYECTO}}` es `[EJEMPLO — reemplazar: una breve descripción de tu proyecto — p. ej. "un servicio que gestiona ítems y permite a cada usuario marcarlos como favoritos"]`.

## Stack

> Completar: lenguajes, frameworks, base de datos / persistencia, librerías clave, y dónde corre. Borrá las líneas que no apliquen.

- `{{STACK}}` — `[EJEMPLO — reemplazar: lenguaje + framework principal]`
- `[EJEMPLO — reemplazar: motor de persistencia / base de datos]`
- `[EJEMPLO — reemplazar: framework de tests + librerías de mock/fixtures]`
- `[EJEMPLO — reemplazar: librerías transversales — validación, mapeo, serialización]`
- `[EJEMPLO — reemplazar: infra / servicios externos — almacenamiento, email, pagos, colas]`

## Commands

> Completar: reemplazá cada bloque por el comando real de tu stack. Si un comando no aplica a tu proyecto (p. ej. no tenés migraciones), borrá su bloque entero.

### Build

```
{{BUILD_COMMAND}}
```

### Test

```
{{TEST_COMMAND}}

# Un solo test / un subconjunto (completar con la sintaxis de filtro de tu runner)
[EJEMPLO — reemplazar: {{TEST_COMMAND}} --filter "<nombre del test>"]
```

### Run Locally

```
{{RUN_COMMAND}}
```

### Migrations / Schema Changes

> **IMPORTANTE — los agentes NO DEBEN ejecutar comandos irreversibles de cambio de esquema o datos.** Nunca corras `{{MIGRATION_COMMAND}}` por tu cuenta. Dejá las migraciones al desarrollador salvo pedido explícito. (Esta regla está reforzada por un hook — ver `## Repo Contracts` y `## Agent Tooling`.)
>
> Si tu proyecto no tiene un paso de migración / cambio de esquema, borrá esta subsección entera.

```
{{MIGRATION_COMMAND}}
```

`[EJEMPLO — reemplazar: convención de nombres de migración, p. ej. "Entidad_DescripcionDelCambio"]`

## Configuration

> Completar: dónde vive la config y qué keys importan. **Regla de oro:** referite a la config **solo por nombre de key** — nunca pegues valores en chat, commits, logs, corridas de test, PRs ni memoria. Si necesitás un valor, pedíselo al usuario inline.

Archivo de config: `[EJEMPLO — reemplazar: ruta del archivo de configuración]`. Los secretos / config local viven en `{{SECRETS_FILE}}` (protegido — ver `## Repo Contracts`).

Keys relevantes (por nombre, sin valores):

- `[EJEMPLO — reemplazar: CONNECTION_STRING — cadena de conexión a la base de datos]`
- `[EJEMPLO — reemplazar: AUTH_SETTINGS — emisor, audiencia, clave de firma, expiración]`
- `[EJEMPLO — reemplazar: <SERVICIO_EXTERNO>_API_KEY — credencial de un servicio externo]`

## Architecture

> Completar: describí tus capas / módulos y cómo se relacionan. NO copies nombres de un stack ajeno — usá los tuyos. El objetivo es que un agente entienda dónde vive cada cosa y cuál es el "hogar natural" de un cambio.

### Layout

```
[EJEMPLO — reemplazar: árbol de carpetas de alto nivel de tu código de producción, con una línea por módulo/capa explicando su responsabilidad]
{{SOURCE_ROOT}}/
  <capa-de-entrada>      – p. ej. controllers / handlers / CLI / endpoints públicos
  <capa-de-dominio>      – entidades, interfaces, modelos, reglas de negocio
  <capa-de-aplicacion>   – lógica que orquesta el dominio (services / use-cases)
  <capa-de-persistencia> – acceso a datos, repositorios, esquema
  <tests>                – suite de pruebas
```

### Layered Pattern

> Completar: una viñeta por capa describiendo qué contiene, qué patrón usa y cómo se conecta con las demás (inyección de dependencias, convención de registro, punto único de acceso a datos, etc.).

- **`[EJEMPLO — reemplazar: Capa de dominio]`** — `[qué contiene: entidades, interfaces, modelos]`.
- **`[EJEMPLO — reemplazar: Capa de aplicación]`** — `[implementa interfaces del dominio; cómo se registra]`.
- **`[EJEMPLO — reemplazar: Capa de persistencia]`** — `[acceso a datos; punto único por el que las capas superiores tocan la base]`.
- **`[EJEMPLO — reemplazar: Capa de entrada]`** — `[expone la funcionalidad; base/convención común]`.

### Cross-cutting Concerns

> Completar: las preocupaciones transversales reales de tu proyecto. Borrá las que no apliquen.

- **Authorization**: `[EJEMPLO — reemplazar: modelo de auth — cómo se identifica al usuario y cómo se decide qué puede hacer]`.
- **Error handling**: `[EJEMPLO — reemplazar: dónde se mapean los errores de dominio al formato de salida — p. ej. excepción "no encontrado" → 404, error de validación → 4xx]`.
- **Response/output shape**: `[EJEMPLO — reemplazar: el envoltorio uniforme de respuesta, si existe — p. ej. { data, success, message, errors }]`.
- **`[EJEMPLO — reemplazar: otras — caching, almacenamiento, notificaciones, pagos]`**.

## Repo Contracts (MUST follow)

> Estos son **invariantes no-negociables** del repo. Aplican a **cualquier agente** (Claude, Cursor, Aider, Codex, Warp) que edite el código. Reemplazá los `[EJEMPLO]` por los contratos reales de tu proyecto, pero **conservá** las dos meta-reglas de seguridad (secretos-por-nombre y no-correr-comandos-irreversibles) — son universales.

### Identity Invariants
`[EJEMPLO — reemplazar: regla de identidad de tus entidades. P. ej. "Create: ignorar el Id entrante — el backend genera el Id. Update: preservar el Id persistido aunque el body traiga otro distinto."]`

### Authorization Model
`[EJEMPLO — reemplazar: las reglas que todo cambio debe respetar al exponer o proteger una operación. P. ej. "toda operación club-scoped exige (a) una política de acceso y (b) un permiso `recurso.nivel`; `.write` satisface `.write` y `.read`; un rol de administrador global puentea los chequeos."]`

### Error → Status Mapping
`[EJEMPLO — reemplazar: el contrato de cómo los errores de dominio se traducen al canal de salida. P. ej. "excepción NoEncontrado → 404; excepción de validación → 4xx; excepción de autenticación → 401". Mantenelo estable: los consumidores dependen de él.]`

### Response Wrapper
`[EJEMPLO — reemplazar: la forma uniforme que devuelve toda operación, si existe. P. ej. "todo endpoint devuelve un envoltorio { data, success, message, errors }".]`

### Config Validation
`[EJEMPLO — reemplazar: qué se valida al arrancar y qué pasa si falta config. P. ej. "el arranque falla rápido si falta una key requerida; nunca degradar silenciosamente a un default inseguro".]`

### Secrets and Local Config (meta-regla — conservar)
**Nunca** modifiques `{{SECRETS_FILE}}` ni reveles sus valores en chat, commits, logs, corridas de test, PRs ni memoria. Referite a la configuración **solo por nombre de key** (p. ej. "la key `CONNECTION_STRING`"). Si hace falta un valor, pedíselo al usuario inline. (Reforzado por el hook `block-protected-file`.)

### Irreversible Commands (meta-regla — conservar)
**Nunca** ejecutes por tu cuenta comandos irreversibles de cambio de esquema o datos (`{{MIGRATION_COMMAND}}` y similares). Quedan reservados al desarrollador salvo pedido explícito. (Reforzado por el hook `block-forbidden-command`.)

## Testing

> Los tests son **mandatorios en todo cambio de comportamiento**. Completar con el runner, la convención de naming, la categorización y la(s) clase(s) base / utilidades de tu suite.

- Todo cambio de comportamiento (lógica de negocio, autorización, capa de entrada) **DEBE** incluir o actualizar tests.
- Convención de naming: `[EJEMPLO — reemplazar: p. ej. Metodo_ResultadoEsperado_CuandoCondicion]`.
- Categorización obligatoria: `[EJEMPLO — reemplazar: marcá cada test como Unit o Integration con el mecanismo de tu runner]`.
- Tests de integración: `[EJEMPLO — reemplazar: qué afirmar — p. ej. el código de estado Y el payload; en casos denegados, que la operación protegida NO se ejecutó]`.
- Cobertura de autorización: `[EJEMPLO — reemplazar: para cada operación protegida, los escenarios mínimos que se deben cubrir — permiso válido, permiso faltante, tipo de credencial equivocado, formato malformado, bypass de admin, etc.]`.
- Utilidades de test: `[EJEMPLO — reemplazar: clase(s) base / fixtures / helpers comunes y dónde viven]`.

## Adding a New Feature

> Receta numerada genérica. Completar / reordenar según tu arquitectura. La idea: que cualquier agente sepa la secuencia de pasos para sumar una pieza nueva sin romper los contratos de arriba.

1. `[EJEMPLO — reemplazar: definir el modelo/entidad y sus interfaces en la capa de dominio]`.
2. `[EJEMPLO — reemplazar: definir los modelos de entrada/salida (DTOs)]`.
3. `[EJEMPLO — reemplazar: implementar la persistencia y registrarla en el punto único de acceso a datos]`.
4. `[EJEMPLO — reemplazar: implementar la lógica de aplicación respetando los Repo Contracts]`.
5. `[EJEMPLO — reemplazar: exponer la operación en la capa de entrada, aplicando el modelo de autorización]`.
6. `[EJEMPLO — reemplazar: agregar el mapeo / serialización necesario]`.
7. `[EJEMPLO — reemplazar: escribir tests unitarios + de integración, incluyendo los escenarios de autorización]`.
8. `[EJEMPLO — reemplazar: si hay cambio de esquema, generar la migración — solo el desarrollador, ver Repo Contracts]`.

## Agent Tooling

El repo organiza su tooling de IA bajo `.claude/`. Cada carpeta tiene un `README.md` que documenta cuándo sumar un ítem de ese tipo.

| Carpeta | Propósito |
|---|---|
| `.claude/agents/` | Subagentes con contexto aislado para trabajo largo y multi-paso: `requirements-analyst` y `requirements-reviewer` (etapa Requisitos: redacción + V&V de requisitos / test de ambigüedad), `solution-designer`, `spec-analyst`, `validator`, `builder`, `e2e-tester` (este último OPCIONAL — solo si tu proyecto expone una interfaz que otros consumen). |
| `.claude/commands/` | Slash commands del flujo SDD: `/spec`, `/plan`, `/tasks`, `/analyze`, `/verify` y `/contract` (`/contract` es OPCIONAL — ver abajo). |
| `.claude/skills/` | Workflows estructurados invocables vía `/<name>` con herramientas restringidas (p. ej. `setup` — onboarding guiado —, `clarify` — protocolo de preguntas por fase para evitar suposiciones silenciosas —, `validate-specs` — gate determinístico del proceso SDD — y `bug-finder`). |
| `.claude/rules/` | Reglas atomizadas. Por defecto las reglas viven centralizadas en este archivo y en `CLAUDE.md` (ver el README de esa carpeta para los criterios de migración). |
| `.claude/hooks/` | Scripts de shell que el harness ejecuta en eventos (`PreToolUse`, `PostToolUse`, etc.). Registrados en `.claude/settings.json`. |

### Spec-Driven Development (proceso mandatorio para features)

Este repo trabaja **SDD-first**: el trabajo que dispara cualquiera de las señales de triage de `specs/CONSTITUTION.md §1` pasa por el flujo spec-driven **antes** de escribir código de feature. Los arreglos triviales/mecánicos son la única excepción.

- **Modelo de artefactos** — viven bajo `specs/NNN-<slug>/`: `spec.md` (comportamiento + criterios de aceptación), `plan.md` (el cómo, reusando el hogar natural), `tasks.md` (checklist atómico, incluye los tests mandatorios). Catálogo en `specs/INDEX.md`; templates bajo `specs/TEMPLATE/`.
- **Contract-first (OPCIONAL)** — `contract.md` y el agente `e2e-tester` solo aplican **si tu proyecto expone una interfaz que otros consumen** (API, librería, CLI, schema/formato). En ese caso, `contract.md` — no un prompt ni un MD suelto — es la fuente de verdad de la superficie pública, y el `spec.md` la referencia. Si no aplica, borralos (`GETTING-STARTED.md` explica cómo).
- **Single pointers (sin duplicación acá)** — el flujo, los estados del lifecycle y el mapeo etapa→comando→agente viven en `specs/README.md`; las reglas no-negociables del proceso y la lista de señales de triage, en `specs/CONSTITUTION.md`; la clasificación de comportamiento (en qué bucket cae un pedido, y el override del dev) en `CLAUDE.md`.
- **Lifecycle** — los estados de un artefacto (`draft` → `approved` → `proposed` → `shipped`/`done`) y las transiciones se gobiernan desde `specs/README.md`. Una spec no pasa a `approved` con marcadores `[VERIFICAR]` abiertos.
- **Gate determinístico + CI** — el skill `validate-specs` (`.claude/skills/validate-specs/`, runners `.ps1`/`.sh`) chequea en frío los gates de proceso objetivos y corre en CI en cada PR (`.github/workflows/sdd-validation.yml`); **refuerza, no reemplaza** los criterios de salida y `/analyze`. La trazabilidad de aprobaciones va versionada en el frontmatter (`approved-by:` / `approved-date:`).

### Active hooks (defensa en profundidad de los Repo Contracts)

- `block-forbidden-command` (`PreToolUse` Bash) — bloquea el comando irreversible de cambio de esquema/datos (`{{MIGRATION_COMMAND}}`). Refuerza el contrato de `## Commands > Migrations` y `## Repo Contracts > Irreversible Commands`.
- `block-protected-file` (`PreToolUse` Edit/Write) — bloquea ediciones a `{{SECRETS_FILE}}`. Refuerza el contrato de `## Repo Contracts > Secrets and Local Config`.

### OPCIONAL — proyectos multi-repo

> Borrá esta subsección si trabajás en un solo repo (el caso por defecto).

Cuando la interfaz la **posee** un repo (dueño-de-contrato) y otros la **consumen** (consumidores), el `contract.md` del dueño es la fuente única de verdad de la superficie pública. Cada repo numera su propia secuencia `NNN`. Los consumidores referencian el contrato **por path** (key `contract:` en el frontmatter de su `spec.md` ↔ key `consumers:` en el `contract.md` del dueño) y **no** re-describen los tipos/DTOs. La coordinación cross-repo (p. ej. un feeder de pendientes cuyos gaps abiertos graduan a filas `proposed` en `specs/INDEX.md`) se mantiene fuera del camino principal single-repo.
