# Getting started — adoptar agentic-sdlc

Este kit no es una librería que instalás: es un **esqueleto que copiás y rellenás**. La estructura (comandos, agentes, hooks, plantillas, gobernanza) ya está; lo que falta son los **hechos de tu proyecto**. Esta guía te lleva de "cloné el repo" a "hice mi primera feature con `/verify`".

> **Distribución:** no hay script de scaffolding. Cloná (o copiá) el repo a tu proyecto nuevo y rellenalo **a mano** siguiendo esta guía. Es deliberado: rellenar los tres archivos de abajo te obliga a decidir tu stack y tus contratos, que es exactamente el trabajo que SDD quiere que hagas antes de codear.

---

## 1. Los 3 archivos que SÍ o SÍ tenés que rellenar antes de codear

No empieces ninguna feature hasta tener estos tres con contenido **real** (no placeholders):

| # | Archivo | Qué llenás | Por qué bloquea |
|---|---|---|---|
| 1 | **`AGENTS.md`** | Los **hechos** del repo: stack, comandos (`{{BUILD_COMMAND}}`, `{{TEST_COMMAND}}`, `{{RUN_COMMAND}}`, `{{MIGRATION_COMMAND}}`), arquitectura, `{{SOURCE_ROOT}}`, repo contracts. | Es la **autoridad técnica**. Todo agente opera sobre estos hechos; con placeholders, todos alucinan tu stack. |
| 2 | **`specs/CONSTITUTION.md` §4 (Repo contracts)** | Tus **contratos duros**: el mapeo error→resultado observable, cómo se protege la autorización, y la regla de secretos/migraciones (`{{SECRETS_FILE}}`, `{{MIGRATION_COMMAND}}`). | Son los no-negociables que se asumen en **cada** spec y fase. Si quedan como `[EJEMPLO — reemplazar]`, no hay contrato que defender. |
| 3 | **`CLAUDE.md` → bloque "Convenciones del proyecto (completar)"** | Las convenciones de comportamiento específicas de tu repo que el gate de triage usa para clasificar y para implementar. | Es la capa de comportamiento sobre la que Claude decide ruta rápida vs SDD. Vacío = clasificación a ciegas. |

> **Atajo guiado:** el skill `/setup` hace esta entrevista por vos — te pregunta por categorías (stack, comandos, arquitectura, contratos, testing) y **llena los tres archivos con tu confirmación** (confirmás cada bloque; no inventa nada). Podés usarlo en lugar de llenarlos a mano; el resto de esta guía vale igual.

> Mientras tanto, conviene también dar una pasada por `specs/CONSTITUTION.md §1` (las **señales de triage**): es la fuente única de verdad a la que apuntan los demás docs. Sus `[EJEMPLO — reemplazar]` describen la **forma** de las señales; ajustalas a las superficies reales de tu proyecto.

---

## 2. La convención de placeholders

El kit marca todo lo que tenés que tocar con tres marcadores. Aprendé a distinguirlos:

- **`{{TOKEN}}`** — un valor concreto que **DEBÉS reemplazar**. Tokens canónicos:
  - `{{PROYECTO}}` — nombre de tu proyecto.
  - `{{BUILD_COMMAND}}` — comando de build/compilación.
  - `{{TEST_COMMAND}}` — comando que corre los tests.
  - `{{RUN_COMMAND}}` — comando que levanta/ejecuta la app.
  - `{{SOURCE_ROOT}}` — raíz del código de producción.
  - `{{SECRETS_FILE}}` — archivo de secretos/config local (el que **nunca** se toca ni se revela).
  - `{{MIGRATION_COMMAND}}` — comando de cambio de esquema/datos, si aplica.
  - *Algunos archivos opcionales agregan tokens propios de su contexto, que solo llenás si usás esa parte:* `{{STACK}}` (en `AGENTS.md`) y —solo si conservás la fase Contrato— `{{LOG_DIR}}`, `{{BASE_URL}}`, `{{LOGIN_ENDPOINT}}`, `{{HTTP_CLIENT}}` (en `e2e-tester`) y `{{E2E}}` (en `validator`). El barrido `grep -rn "{{"` los encuentra a todos.
- **`[EJEMPLO — reemplazar]`** — un bloque ilustrativo que se deja inline para que veas la **forma** (una regla de ejemplo, un criterio de aceptación de ejemplo, un invariante de ejemplo). Lo editás con tu caso real o lo borrás.
- **`[VERIFICAR]`** — una pregunta abierta dentro de una spec/contrato. **Bloquea** el paso a `approved`: no se construye contra una spec con `[VERIFICAR]` sin resolver. (Este token queda en español tal cual.)

### Lista de búsqueda para barrer

Antes de codear, **grepeá el repo** y resolvé lo que aparezca. Desde la raíz:

```sh
# 1) Todos los valores a reemplazar
grep -rn "{{" .

# 2) Todos los bloques ilustrativos a editar o borrar
grep -rn "\[EJEMPLO" .

# 3) Preguntas abiertas que bloquean approved (deberían ser 0 antes de aprobar una spec)
grep -rn "\[VERIFICAR\]" .
```

> En PowerShell: `Get-ChildItem -Recurse | Select-String '{{'` (y equivalentes para `[EJEMPLO` y `[VERIFICAR]`). El objetivo es el mismo: que ningún `{{TOKEN}}` ni `[EJEMPLO — reemplazar]` sobreviva en los archivos de gobernanza una vez adaptado el kit.

---

## 3. Checklist de personalizar / borrar

### 3.1. ¿Tu proyecto expone una interfaz que otros consumen?

Una interfaz = una API, una librería, un CLI, o un schema/formato de datos que **algo externo a tu código depende de su forma**.

- **SÍ →** quedate con la **fase Contrato**: conservá `/contract` (`.claude/commands/contract.md`), el agente `e2e-tester` (`.claude/agents/e2e-tester.md`), la plantilla `specs/TEMPLATE/contract.md` y la §2 (Contract-first) de `CONSTITUTION.md`. Llenalos.
- **NO →** **borralos**:
  - `.claude/commands/contract.md`
  - `.claude/agents/e2e-tester.md`
  - `specs/TEMPLATE/contract.md`
  - la §2 de `specs/CONSTITUTION.md` (y las menciones a `e2e-tester` en `specs/README.md`: §0 Contrato, §7 Verify y la fila 7 de la tabla de fases)
  - el `contract:` del frontmatter en tus specs queda como `n/a (no expone interfaz nueva)`.

  (El ejemplo `specs/000-EXAMPLE-feature/` incluye `contract.md` a propósito, para que veas la fase aunque después la borres.)

### 3.2. Elegí y editá tus hooks

Los dos hooks vienen como **plantillas**: el patrón que bloquean es genérico. Editá el patrón interno para que apunte a **tu** comando/archivo real, y renombralos si querés que digan algo más específico de tu proyecto.

- **`block-forbidden-command.{ps1,sh}`** — bloquea un comando Bash prohibido. Por defecto apunta a `{{MIGRATION_COMMAND}}` (un cambio de esquema/datos que solo un humano debe correr). Editá el patrón regex dentro del script con tu comando real.
- **`block-protected-file.{ps1,sh}`** — bloquea Edit/Write sobre un archivo protegido. Por defecto apunta a `{{SECRETS_FILE}}`. Editá el patrón de path dentro del script.

Si un hook no aplica a tu proyecto, borrá su par `.ps1`/`.sh` **y** su entrada en `settings.json`. El detalle de cómo escribir/registrar hooks está en `.claude/hooks/README.md`.

### 3.3. Elegí la variante de hook: PowerShell o POSIX

Cada hook se shipea en **dos runners gemelos** con la misma lógica: `*.ps1` (PowerShell) y `*.sh` (POSIX). El template **registra los `.ps1` por defecto** en `.claude/settings.json`. Elegí según tu entorno:

- **Windows (PowerShell):** dejá los `.ps1` registrados. Launcher: `powershell -NoProfile -ExecutionPolicy Bypass -File ...` (o `pwsh ...` si usás PowerShell 7).
- **Linux / macOS (POSIX):** en `settings.json`, cambiá el launcher `powershell ... -File .../<hook>.ps1` por `sh .../<hook>.sh`. El contrato stdin/stdout es idéntico, no toques la lógica.

Ver `.claude/hooks/README.md` → "Cross-platform" para los launchers exactos.

### 3.4. El gate determinístico (validador + CI)

El kit trae un **validador determinístico** que convierte los gates de proceso en chequeos que **fallan solos** (no dependen de que alguien recuerde la regla):

- **A mano / localmente:** corré el skill `/validate-specs` (o directo `powershell -NoProfile -File .claude/skills/validate-specs/validate-sdd.ps1` · `sh .claude/skills/validate-specs/validate-sdd.sh`) antes de aprobar/cerrar una spec.
- **En CI:** `.github/workflows/sdd-validation.yml` lo corre en cada PR. Si no usás GitHub Actions, replicá la idea en tu CI. Descomentá el job de build/test y completá `{{BUILD_COMMAND}}`/`{{TEST_COMMAND}}`.

Chequea: `[VERIFICAR]` abiertos en specs `approved`/`done`, `approved-by:` faltante, criterios sin tildar, `contract:` roto, fila en `INDEX.md`. Lo semántico (cobertura, calidad del criterio) queda en `/analyze` + el ingeniero. Funciona out-of-the-box sobre el ejemplo `000-*`; cuando lo borres, valida tus propias specs.

---

## 4. Tu primera corrida (camino completo hasta `/verify`)

Con los tres archivos de la sección 1 ya llenos, hacé una feature de prueba de punta a punta:

1. **`/spec marcar ítems como favoritos`**
   El `requirements-analyst` arranca `spec.md`, propone criterios de aceptación y **te pregunta** hasta que no quede ningún `[VERIFICAR]`. Resolvelos → la spec pasa a `approved`. Registra su fila en `INDEX.md`.
2. **`/contract`** *(solo si tu proyecto expone una interfaz)*
   Define la forma de la superficie (firmas, campos, errores, autorización). Status `proposed`.
3. **`/plan`**
   El `solution-designer` escribe `plan.md`: el enfoque técnico, **qué reutilizás** (no duplicar), los cambios archivo por archivo, los riesgos. Lo aprobás vos.
4. **`/tasks`**
   `tasks.md`: checklist atómica donde cada tarea está atada a un criterio de aceptación (columna "Cubre AC"), con las tareas de test obligatorias. Corre en el hilo principal.
5. **`/analyze`**
   El `spec-analyst` chequea consistencia **antes** de codear: ¿cada criterio tiene tareas que lo cubren? ¿el plan respeta el contrato y la CONSTITUTION? ¿hay scope creep? Se corrige acá, que es barato.
6. **Implementar**
   El `builder` ejecuta las tareas siguiendo `AGENTS.md` + `CLAUDE.md` + `CONSTITUTION.md`, marcando cada tarea en `tasks.md` al completarla.
7. **`/verify`**
   El `validator` recorre **cada criterio de aceptación** con evidencia (`archivo:línea` y/o comportamiento real), corre `{{BUILD_COMMAND}}` y `{{TEST_COMMAND}}` (y `e2e-tester` si hay contrato). Con todos los AC en ✅ → `status: done`; el contrato pasa a `shipped`; se actualiza `INDEX.md`.

> **Regla de oro:** una feature no está `done` hasta pasar `/verify` con **todos** los criterios de aceptación en ✅.

> **Antes de cada aprobación** (`/spec`, `/plan`, `/verify`) corré **`/validate-specs`**: el chequeo determinístico que ataja los olvidos mecánicos (`[VERIFICAR]` abiertos, criterios sin tildar, `approved-by:` faltante). Al pasar a `approved`/`done`, completá `approved-by:` en el frontmatter — el validador lo exige.

El proceso completo, fase por fase, está en `specs/README.md`. El paso a paso para el equipo, en `specs/GUIA-EQUIPO-SDD.md`.

---

## 5. El ejemplo read-only

`specs/000-EXAMPLE-feature/` es una feature **completa y llena** ("el usuario puede marcar ítems como favoritos y ver su lista de favoritos") que muestra cómo se ve cada artefacto una vez terminado: un golden-path, un caso de borde/error, uno de autorización y un invariante de persistencia, criterios de aceptación true/false, plan, tasks y contrato.

Cada archivo abre con:

> ⚠️ EJEMPLO de referencia — no lo edites; borralo cuando ya entiendas el flujo.

Usalo de referencia mientras hacés tu primera feature. **Cuando ya entendés el flujo, borrá la carpeta entera** (`specs/000-EXAMPLE-feature/`) — es read-only y no es parte de tu proyecto. Tu primer `NNN` real es `001` (próximo libre del `INDEX.md`).

---

## 6. Nota de idioma

El kit está escrito en **español (rioplatense)** para toda la prosa humana y los system-prompts de los agentes. En inglés quedan, a propósito: las keys de frontmatter YAML, los enums de estado (`draft`/`approved`/`proposed`/`shipped`/`done`), los archivos de config, los comentarios de los scripts de hooks y la jerga SDD ya anglosajona.

Un equipo que prefiera trabajar en inglés **puede traducir la prosa**: la estructura (carpetas, comandos, agentes, frontmatter, flujo) es **independiente del idioma**. Traducí los `.md` de prosa y dejá las keys/enums/config como están.

---

## Resumen ultra-corto

1. Llená `AGENTS.md`, `CONSTITUTION.md §4` y el bloque "Convenciones del proyecto" de `CLAUDE.md` — a mano, o guiado con **`/setup`**.
2. `grep -rn "{{" .` y `grep -rn "\[EJEMPLO" .` → reemplazá todo.
3. ¿Exponés interfaz? No → borrá `/contract`, `contract.md`, `e2e-tester`.
4. Elegí runner de hooks (`.ps1` vs `.sh`) y editá su patrón.
5. `/spec marcar ítems como favoritos` → caminá hasta `/verify`.
6. Borrá `specs/000-EXAMPLE-feature/` cuando entiendas el flujo.
7. Corré `/validate-specs` antes de cada aprobación (y completá `approved-by:` en el frontmatter).
