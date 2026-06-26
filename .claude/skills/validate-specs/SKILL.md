---
name: validate-specs
description: Corre el validador DETERMINÍSTICO de artefactos SDD (gates de proceso "duros", no conductuales). Usar antes de aprobar/cerrar una spec, en cada PR vía CI, o cuando se pida "validá las specs", "chequeá el proceso SDD", "corré el validador". Falla si una spec avanzó de fase con [VERIFICAR] abiertos, sin approved-by, o con criterios sin tildar.
---

# /validate-specs — gate determinístico del proceso SDD

Esta skill corre el **validador determinístico** que convierte en chequeos automáticos los gates de proceso que de otro modo serían solo **conductuales** (dependen de que la IA/humano recuerde la regla). Es la contraparte **dura** de los *Criterios de salida (V&V de fase)*: lo **semántico** (cobertura criterio↔tarea, calidad del criterio) lo cubren `/analyze` y el ingeniero; esto cubre lo **mecánico y objetivo**, y falla solo.

## Cuándo correrla

- **Antes** de marcar una spec/contrato como `approved` / `shipped` / `done`.
- En **CI**, en cada PR — ver `.github/workflows/sdd-validation.yml`.
- Cuando quieras un chequeo rápido del estado del proceso.

## Qué chequea (por cada `specs/NNN-*/`)

- Una spec `approved` / `in-progress` / `done` **no** tiene `[VERIFICAR]` vivos (sin tachar con `~~`).
- Una spec que avanzó de fase tiene **`approved-by:`** poblado (trazabilidad de la decisión humana).
- Una spec `done` **no** tiene criterios de aceptación / criterios de salida sin tildar (`- [ ]`).
- El frontmatter tiene las keys mínimas (`name`, `status`).
- El `contract:` referenciado **existe** en disco (cross-ref no roto).
- Un `contract.md` `shipped` no tiene `[VERIFICAR]` vivos y tiene `approved-by:`.
- *(WARN)* la feature tiene fila en `INDEX.md`.

Excluye `specs/TEMPLATE/` (placeholders). Exit `1` si hay errores, `0` si no; los **WARN** no fallan.

## Cómo correrla

Mismo comportamiento en ambos runners — elegí según tu entorno:

- **Windows / PowerShell:**
  ```
  powershell -NoProfile -ExecutionPolicy Bypass -File .claude/skills/validate-specs/validate-sdd.ps1
  ```
- **Linux / macOS / CI (POSIX):**
  ```
  sh .claude/skills/validate-specs/validate-sdd.sh
  ```

Opcional: pasá el directorio de specs (`-SpecsDir specs` en PowerShell · `validate-sdd.sh specs` en POSIX). Default: `specs`.

## Cómo extenderla

- Los chequeos **semánticos** son del agente `spec-analyst` vía `/analyze`, **no** de este script — mantené esa división (lo determinístico acá, lo que requiere criterio allá).
- Si sumás un gate de proceso nuevo y **objetivo** (greppeable), agregalo a **los dos** scripts (`.ps1` y `.sh`) para que sigan en paridad, y documentá el chequeo acá.
- Para enforcement local automático, podés cablear el script como hook en `.claude/settings.json` (ver `.claude/hooks/README.md`); por defecto el gate vive en CI + corrida manual, para no friccionar el día a día.
