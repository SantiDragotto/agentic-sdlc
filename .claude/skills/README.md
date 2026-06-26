# `.claude/skills/`

Workflows estructurados de Claude Code. Cada skill vive en `<name>/SKILL.md` con frontmatter, descripción de auto-trigger y pasos.

## Cuándo crear un skill (vs command vs agent)

Elegí **skill** cuando:

- El workflow tiene **fases con sub-pasos** (no un atajo de una línea).
- Necesitás **restringir tools** (`allowed-tools` en frontmatter).
- Querés que Claude lo **invoque automáticamente** según la `description` (auto-trigger).
- Querés agrupar el workflow con **archivos auxiliares** (templates, helpers) en la misma carpeta.

Para atajos cortos sin restricción de tools, usar **commands** (`.claude/commands/`). Para tareas autónomas largas con context isolation, usar **agents** (`.claude/agents/`).

## Frontmatter requerido

```yaml
---
name: <kebab-case>
description: <texto detallado para auto-trigger — Claude lo matchea contra el pedido del usuario>
argument-hint: <ej: "[--all | --file <path>]">
allowed-tools: <lista: Read, Glob, Grep, Bash, mcp__<server>__<tool>, ...>
---
```

Las cuatro keys (`name`, `description`, `argument-hint`, `allowed-tools`) van en inglés (keys de frontmatter); el valor de `description` se escribe en español porque es la prosa que Claude matchea contra el pedido del usuario.

## Convenciones

- Estructura: `.claude/skills/<name>/SKILL.md`. Helpers opcionales en la misma carpeta (`.claude/skills/<name>/template.json`, etc.).
- Nombre: kebab-case (`bug-finder`, `docs-sync`).
- Workflow numerado por pasos con verificaciones de cobertura cuando aplique.
- Side-effects predecibles: documentar al final del skill qué archivos toca.

## Activos en este repo

Las **4 skills** activas del kit:

| Skill | Qué hace | Cuándo se dispara |
|---|---|---|
| `bug-finder` | Auditoría iterativa exhaustiva del código trabajado, hasta convergencia. | `/bug-finder`, "revisá el código", "buscá bugs", "code review". |
| `validate-specs` | Gate **determinístico** del proceso SDD (scripts `validate-sdd.{ps1,sh}` + CI). | Antes de aprobar/cerrar una spec, en cada PR, "validá las specs". |
| `setup` | Onboarding guiado: entrevista al adoptante y llena los 3 archivos obligatorios. | "configurar el kit", "setup del proyecto", `/setup`. |
| `clarify` | Protocolo de preguntas en CADA fase del SDD (la IA no asume en silencio). | Cualquier fase del flujo, "no asumas", "clarificá". |

> Cada skill vive en `<name>/SKILL.md` (con sus archivos auxiliares si los tiene — p. ej. los runners `validate-sdd.{ps1,sh}` de `validate-specs`). El detalle completo de cada una está en su `SKILL.md`.

[EJEMPLO — reemplazar] Cuando agregues skills propios a tu repo, sumalos a la tabla de arriba igual que los del kit: una línea por skill (qué hace + cuándo se dispara).

## Roadmap

[EJEMPLO — reemplazar] Ideas de skills a futuro para tu proyecto. Borrá lo que no aplique:

- `<test-scaffold>` — genera los casos de prueba obligatorios para un patrón recurrente (template puro, sin lógica). [EJEMPLO — reemplazar]
- `<add-entity>` — envuelve un workflow repetitivo documentado en `AGENTS.md` (ej. "agregar una entidad nueva"). [EJEMPLO — reemplazar]
- `<doctor>` — checklist post-cambio-estructural ({{MIGRATION_COMMAND}}, etc.). [EJEMPLO — reemplazar]

## Patrón de referencia: skill de sincronización de docs con tabla de cobertura

Un patrón muy reutilizable es una skill que **mantiene un documento externo en sincronía con el código** y exige una **tabla de cobertura obligatoria** antes de declararse terminada. Sirve para mantener al día un catálogo de la interfaz pública: endpoints de una API, comandos de un CLI, entradas de un schema/formato, símbolos exportados de una librería, etc.

Forma general (implementala según tu stack y tu destino de documentación):

1. **Detectar el delta.** Resolver qué cambió desde una base (`git diff` contra `main`, o contra el último estado sincronizado) y extraer las unidades de interfaz afectadas del código fuente (los archivos bajo `{{SOURCE_ROOT}}`).
2. **Mapear código → doc.** Para cada unidad de interfaz detectada, ubicar la fila/entrada correspondiente en el destino de documentación (una página, una tabla, un archivo markdown, un MCP de documentación vía `mcp__<server>__<tool>`, lo que uses).
3. **Tabla de cobertura obligatoria.** Antes de terminar, emitir una tabla que liste **cada** unidad de interfaz del delta con su estado: `creada` / `actualizada` / `sin-cambios` / `FALTA`. La skill **no puede declararse completa** mientras quede una fila en `FALTA`. Esta tabla es la salvaguarda central del patrón: hace imposible "olvidarse" de documentar algo que cambió.
4. **Reportar.** Resumir qué se sincronizó y qué quedó pendiente con decisión humana.

`allowed-tools` típico para este patrón: `Read, Glob, Grep, Bash` (lectura de código y git) más la tool de escritura del destino de documentación (`Edit`/`Write` si es un archivo del repo, o `mcp__<server>__<tool>` si es un sistema externo).
