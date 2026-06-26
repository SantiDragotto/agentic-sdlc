---
name: setup
description: Onboarding guiado que entrevista al adoptante para llenar los 3 archivos obligatorios del kit (AGENTS.md, CONSTITUTION.md §4, bloques de CLAUDE.md). Usar cuando el usuario pide "configurar el kit", "setup del proyecto", "arrancar el proyecto", invoca "/setup", o pide "llenar AGENTS.md/constitución". NO escribe código del proyecto ni specs — solo gobernanza.
argument-hint: "[--lang es|en]"
allowed-tools: Read, Grep, Glob, Edit, Write
---

# /setup — onboarding guiado del kit SDD

Argumentos: `$ARGUMENTS`

Esta skill es la **alternativa GUIADA** al llenado manual descrito en `GETTING-STARTED.md`. No es obligatoria —podés rellenar los archivos a mano siguiendo esa guía— pero **baja la fricción**: te entrevista por categorías, propone un valor por defecto en cada una y lo escribe por vos una vez que lo confirmás. El trabajo de decidir tu stack y tus contratos sigue siendo tuyo; la skill solo te lo ordena y lo transcribe.

## Qué hace y qué NO hace

- **Hace:** entrevista al adoptante, propone valores, y —tras confirmación humana— reemplaza los `{{TOKEN}}` y los bloques `[EJEMPLO — reemplazar]` en los **3 archivos obligatorios**: `AGENTS.md`, `specs/CONSTITUTION.md §4`, y los bloques **"Convenciones del proyecto (completar)"** + **"Contratos duros del repo"** de `CLAUDE.md`. Aplica las decisiones de configuración (¿expone interfaz?, runner de hooks, idioma).
- **NO hace:** no escribe código del proyecto, no crea specs de trabajo (`specs/NNN-*/`), no toca el ejemplo `000-EXAMPLE-feature/` ni `TEMPLATE/`, no corre migraciones, **nunca** inventa ni escribe valores de `{{SECRETS_FILE}}` (solo registra su *nombre/ruta*).

## Principio rector (regla dura)

**El humano decide.** Por cada categoría, la skill **propone** un valor y **pide confirmación explícita** antes de escribir; no asume. No avanza a escribir un bloque sin el OK del humano. Confirmar o corregir una propuesta es más rápido que responder en blanco — por eso la skill siempre llega con un default sugerido.

## Paso 0 — Preparación

1. Resolvé el idioma: si `$ARGUMENTS` trae `--lang en`, conducí la entrevista en inglés (igual las keys de frontmatter/enums quedan como están); default `es`.
2. Leé los 3 archivos objetivo para conocer su estado actual: `AGENTS.md`, `specs/CONSTITUTION.md`, `CLAUDE.md`. (Ya conocés su estructura desde el kit; releé solo lo necesario.)
3. Corré un barrido inicial para ver qué falta:
   ```sh
   grep -rn "{{" .
   grep -rn "\[EJEMPLO" .
   ```
   Esto te da el universo de placeholders a resolver. Anunciá al humano cuántos hay y que vas a recorrerlos por categorías.

> Si los archivos **ya están llenos** (pocos `{{` / `[EJEMPLO` sobreviven), ofrecé correr solo el barrido final (Paso 4) en vez de re-entrevistar todo.

## Paso 1 — Entrevista por categorías

Recorré las categorías **en orden**. Por cada una: (a) proponé un valor concreto basado en lo que el humano ya contó y en convenciones comunes del stack que mencione; (b) mostralo; (c) **pedí confirmación o corrección** antes de pasar a la siguiente. No escribís nada todavía —solo juntás respuestas confirmadas.

1. **Nombre del proyecto** → `{{PROYECTO}}`. Una o dos frases de qué es y qué problema resuelve (alimenta `## Project Overview` de `AGENTS.md`).
2. **Stack** → `{{STACK}}` y el bloque `## Stack`: lenguaje + framework principal, motor de persistencia, framework de tests + mocks/fixtures, librerías transversales (validación/mapeo/serialización), infra/servicios externos. Borrá las líneas que no apliquen.
3. **Comandos** → `{{BUILD_COMMAND}}`, `{{TEST_COMMAND}}`, `{{RUN_COMMAND}}`, `{{MIGRATION_COMMAND}}`. Por cada uno proponé el comando idiomático del stack confirmado. Si el proyecto **no tiene migraciones**, marcá para borrar esa subsección entera (no inventes un comando).
4. **Arquitectura / capas** → `## Architecture` (Layout, Layered Pattern, Cross-cutting Concerns) y `{{SOURCE_ROOT}}`. Capturá el árbol de carpetas de alto nivel y una línea por capa (entrada / dominio / aplicación / persistencia / tests), más cómo se cablean (inyección de dependencias, registro, punto único de acceso a datos).
5. **Repo contracts** → poblá `## Repo Contracts` de `AGENTS.md` **y** los recordatorios de `CONSTITUTION.md §4`:
   - **Identidad** (Identity Invariants): regla de IDs en create/update.
   - **Autorización** (Authorization Model): cómo se protege la superficie y se chequea el permiso (decorador/middleware/guard, token/claim, jerarquía de niveles, bypass de admin).
   - **Error → resultado observable** (Error → Status Mapping): mapeo canónico (recurso inexistente → X, violación de regla → Y, auth → Z).
   - **Envoltura de respuesta** (Response Wrapper): la forma uniforme de salida, si existe (`{ data, success, message, errors }` o lo que uses) — o "no aplica".
   - **Validación de config** (Config Validation): qué se valida al arrancar y qué pasa si falta una key (fail-fast vs default).
6. **Convención de testing** → `## Testing` de `AGENTS.md`: convención de naming (`Metodo_ResultadoEsperado_CuandoCondicion` o la tuya), categorización obligatoria (unit/integration), qué afirmar en integración, la matriz mínima de cobertura de autorización, y dónde viven las utilidades/fixtures.
7. **Secretos / config local** → `{{SECRETS_FILE}}`: capturá **solo el nombre/ruta** del archivo de secretos y el archivo de config no-secreto. **Nunca** pidas ni registres valores de secretos; si para algo hiciera falta un valor, se pide inline en el momento, no acá.

> Ante una respuesta ambigua o un contrato/comportamiento que el humano no tiene claro, **no adivines**: dejá ese punto anotado para que el humano lo resuelva, y seguí. Un contrato mal capturado se asume en cada fase y contamina todo.

## Paso 2 — Decisiones de configuración

Tres decisiones que cambian qué archivos quedan en el kit. Proponé el default, confirmá, y anotá la consecuencia:

1. **¿Tu proyecto expone una interfaz que otros consumen?** (API, librería, CLI, schema/formato).
   - **SÍ** → conservar la fase Contrato (`/contract`, `contract.md`, agente `e2e-tester`, §2 de `CONSTITUTION.md`). Hay que llenarlos.
   - **NO** → marcar para **borrar**: `.claude/commands/contract.md`, `.claude/agents/e2e-tester.md`, `specs/TEMPLATE/contract.md`, la §2 de `CONSTITUTION.md` (y las menciones a `e2e-tester` en `specs/README.md`); en las specs futuras el `contract:` queda `n/a (no expone interfaz nueva)`. (Detalle exacto en `GETTING-STARTED.md §3.1`.)
2. **Runner de hooks: PowerShell (`.ps1`) o POSIX (`.sh`)?** El template registra los `.ps1` por defecto en `.claude/settings.json`. Si el adoptante usa Linux/macOS, hay que cambiar el launcher de cada hook a `sh .../<hook>.sh` (ver `GETTING-STARTED.md §3.3`). Anotá la elección; el cambio de `settings.json` lo confirma el humano.
3. **Idioma de la prosa.** Default español (rioplatense). Si el equipo prefiere inglés, la prosa se puede traducir pero las keys de frontmatter, enums de estado y config quedan como están (`GETTING-STARTED.md §6`).

## Paso 3 — Escribir los valores confirmados

Solo con todo confirmado, aplicá los reemplazos. **Un bloque por vez, mostrando el antes/después al humano** antes de cada escritura cuando el bloque es sustancial:

- **`AGENTS.md`** — reemplazá `{{PROYECTO}}`, `{{STACK}}`, `{{BUILD_COMMAND}}`, `{{TEST_COMMAND}}`, `{{RUN_COMMAND}}`, `{{MIGRATION_COMMAND}}`, `{{SOURCE_ROOT}}` y los bloques `[EJEMPLO — reemplazar]` de Overview, Stack, Commands, Architecture, Repo Contracts y Testing por los valores confirmados. Conservá **intactas** las dos meta-reglas de seguridad (secretos-por-nombre, no-correr-comandos-irreversibles) y el nombre `{{SECRETS_FILE}}` se reemplaza por la **ruta**, nunca por valores.
- **`specs/CONSTITUTION.md §4 (Repo contracts)`** — reemplazá los tres bullets `[EJEMPLO — reemplazar]` (errores, autorización, secretos/config) por el resumen de los contratos reales confirmados en el Paso 1.5. Si el proyecto **no** expone interfaz y se decidió borrar la fase Contrato, eliminá también la §2.
- **`CLAUDE.md`** — reemplazá:
  - el bloque **"Convenciones del proyecto (completar)"** (los bullets `[EJEMPLO — reemplazar]`) por las convenciones duras reales: cómo se registran/cablean componentes, cómo se accede a la persistencia, qué base extender en vez de reimplementar, cómo fluyen los errores.
  - el bloque **"Contratos duros del repo (ejemplos — reemplazar)"** (invariantes de ID, autorización, target framework, secretos, migraciones) por los contratos reales — consistentes con lo que ya escribiste en `AGENTS.md`/`CONSTITUTION.md`.

> **No** toques `specs/TEMPLATE/`, `specs/000-EXAMPLE-feature/`, ni crees ninguna `specs/NNN-*/`. Esos son referencia/plantilla. La skill llena **gobernanza**, no produce trabajo de feature.

## Paso 4 — Cierre

1. **Barrido final.** Volvé a correr el grep de placeholders y reportá lo que sobrevive:
   ```sh
   grep -rn "{{" .
   grep -rn "\[EJEMPLO" .
   ```
   El objetivo es que **ningún** `{{TOKEN}}` ni `[EJEMPLO — reemplazar]` quede en los archivos de gobernanza. Lo que reste en archivos opcionales no usados (p. ej. tokens de `e2e-tester` si se borró la fase Contrato) se resuelve borrando ese archivo, no rellenándolo. Listá explícitamente qué queda y por qué.
2. **Recordá los borrados pendientes** decididos en el Paso 2 (fase Contrato, hook del runner no elegido) — la skill los **marca**; el humano confirma cada borrado real de archivos.
3. **Próximos pasos sugeridos:**
   - Correr **`/validate-specs`** para el gate determinístico del proceso.
   - Arrancar la primera feature con **`/spec <brief de la feature>`** y caminar hasta `/verify` (camino completo en `GETTING-STARTED.md §4`).
   - Borrar `specs/000-EXAMPLE-feature/` cuando se entienda el flujo.

## Reglas duras (resumen)

- El humano **confirma cada bloque** antes de que se escriba. Sin OK no se escribe.
- **Nunca** se inventan ni se escriben valores de `{{SECRETS_FILE}}` — solo su nombre/ruta.
- La skill **no** escribe código del proyecto ni specs; solo los 3 archivos de gobernanza (+ las decisiones de config).
- Ante ambigüedad de un contrato/comportamiento, se **anota para el humano**, no se adivina.
- No se corre `{{MIGRATION_COMMAND}}` ni se tocan archivos protegidos por hooks.

## Side-effects

Edita: `AGENTS.md`, `specs/CONSTITUTION.md`, `CLAUDE.md`. Marca (no borra automáticamente) archivos de la fase Contrato y el runner de hook no elegido para que el humano los borre. No crea ni modifica ningún `specs/NNN-*/`, `TEMPLATE/`, ni `000-EXAMPLE-feature/`.
