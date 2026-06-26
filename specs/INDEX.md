# Índice de specs — {{PROYECTO}}

Catálogo vivo. Actualizar al crear/cerrar una spec o contrato.

- **Spec:** `draft` · `approved` · `in-progress` · `done` · `superseded`
- **Contrato (OPCIONAL):** `proposed` · `approved` · `shipped` — solo si tu proyecto expone una interfaz que otros consumen (API, librería, CLI, schema/formato). Si no aplica, dejá la columna en `n/a`.

> **OPCIONAL — proyectos multi-repo:** Numeración **propia de este repo** (próximo `NNN` libre de esta tabla). En un setup single-repo el `NNN` es simplemente el orden de tus features. En multi-repo **el número no cruza repos**: el join con los consumers es por path — columna "Consumers" acá ↔ campo `contract:` en la spec del repo consumidor (ver `README.md §Multi-repo`).

## Features con spec/contrato

| NNN | Título | Spec | Contrato | Consumers (paths) |
|---|---|---|---|---|
| `000-example-feature` | _EJEMPLO de referencia — favoritos (marcar ítems y ver la lista)_ | **done** | **shipped** | n/a (single-repo) |
|  |  |  |  |  |

> La fila `000-example-feature` es un **ejemplo de referencia** (ver `specs/000-EXAMPLE-feature/`): muestra la forma de una feature completa con su `contract.md`. **No la edites; borrala** —junto con su carpeta— cuando ya entiendas el flujo. Las features nuevas arrancan por la spec (`/spec NNN-slug`).

## Cómo agregar una fila

Al correr `/spec NNN-slug` (o `/contract NNN-slug`, si tu proyecto expone una interfaz), agregá la feature acá con su status:

1. **NNN** — próximo número de 3 dígitos libre de esta tabla. **Título** — frase corta y descriptiva.
2. **Spec** — el estado del ciclo (`draft` → `approved` → `in-progress` → `done`). Usá `n/a` si la feature se documentó as-built sin spec.
3. **Contrato** — `n/a` si no expone interfaz; si la expone, su estado (`proposed` → `approved` → `shipped`).
4. **Consumers** — `n/a` en single-repo. En multi-repo, el/los path(s) del repo consumidor que dependen del contrato (ver `README.md §Multi-repo`).

Al pasar a `done`/`shipped`, actualizá el status. Si tu proyecto expone una interfaz y cambiás un contrato `shipped`, avisá a cada consumer listado en la columna "Consumers".

## Backlog (proposed)

> Ideas o gaps **abiertos** que todavía no se diseñaron. Cada uno se promueve a feature con `/spec` (o `/contract`) cuando se retome. Dejá una línea por item con suficiente contexto para retomarlo en frío.

| Gap | Origen | Estado |
|---|---|---|
| [EJEMPLO — reemplazar] Validar que el límite de favoritos por usuario sea configurable (hoy hardcodeado) | hallazgo del inbox (`HALLAZGOS.md`) | proposed |
|  |  |  |
