---
name: bug-finder
description: Auditoría iterativa exhaustiva del código trabajado en la sesión/branch. Usar cuando el usuario invoca /bug-finder, o pide "revisá el código", "auditá lo que hicimos", "buscá bugs", "revisión de calidad", "code review". Ejecuta ciclos de revisión hasta que dos loops consecutivos no encuentren nada nuevo (máximo 8 loops).
argument-hint: "[--scope <paths> | --all-changes]"
allowed-tools: Read, Glob, Grep, Bash, Edit, Agent, TaskCreate, TaskUpdate
---

# bug-finder — Auditoría iterativa de código hasta convergencia

Argumentos: `$ARGUMENTS`

## Objetivo

Dejar el código que se estuvo trabajando libre de bugs, inconsistencias y errores conceptuales, ejecutando ciclos de revisión hasta que dos ciclos consecutivos no encuentren nada nuevo.

## Paso 0 — Determinar alcance

### 0A — Archivos a auditar

Resolver el set de archivos según argumentos:

- **`--scope <paths>`:** solo los paths indicados (glob válido).
- **`--all-changes`:** todos los cambios vs `main` (union de `git diff`, staged y unstaged).
- **Sin argumentos (default):** cambios sobre `main` — misma lógica que `--all-changes`.

> La branch base por defecto es `main`. Si tu repo usa otra (`master`, `develop`, una release branch), pasala explícitamente o ajustá los comandos de abajo.

```bash
BASE=$(git merge-base HEAD main)
# Commiteados sobre main
git diff --name-only $BASE..HEAD
# Unstaged
git diff --name-only HEAD
# Staged
git diff --name-only --cached
```

Tomar la **unión** de los tres outputs. Filtrar solo archivos de código fuente existentes (las <extensiones de archivos fuente> de tu stack, ej. `.ts`, `.py`, `.go`, `.rs`); ignorar archivos borrados.

### 0B — Leer todos los archivos del alcance

Leer **cada archivo** completo antes del primer loop. También leer las interfaces/contratos que referencian (e.g. si una implementación cumple una interfaz/abstracción/protocolo, leer esa definición). Esto es la base de conocimiento para la auditoría.

### 0C — Entender el requerimiento original

Revisar los commits sobre `main` para entender qué se pidió:
```bash
git log --oneline $BASE..HEAD
```
Leer los mensajes de commit para reconstruir el requerimiento original. Si existe una spec asociada en `specs/NNN-slug/`, leerla también (es la fuente de intención más fuerte). Si hay dudas sobre la intención, preguntar al usuario antes de arrancar los loops.

## Paso 1 — Loop de auditoría (repetir hasta convergencia)

### Estado del loop

Mantener un contador:
- `loop_number`: empezando en 1
- `consecutive_clean`: cuántos loops consecutivos terminaron con 0 hallazgos
- `total_fixes`: acumulado de correcciones aplicadas

### 1A — Releer desde cero

En cada loop, releer **todos** los archivos del alcance desde cero. No asumir que loops previos dejaron todo limpio — la corrección de un bug puede introducir otro.

### 1B — Categorías de revisión

Revisar en este orden, listando TODOS los problemas encontrados ANTES de corregir:

#### 1. Bugs funcionales
- Lógica incorrecta (condiciones invertidas, operadores equivocados)
- Casos borde no manejados
- Off-by-one
- Null/undefined/valor vacío sin chequeo donde puede explotar
- Race conditions o problemas de concurrencia
- Operaciones async sin esperar (await/join/then) que se pierden
- Excepciones/errores tragados silenciosamente
- Queries o accesos a datos que pueden devolver resultados inesperados

#### 2. Inconsistencias
- Naming inconsistente (convenciones de casing mezcladas, prefijos distintos)
- Tipos que no matchean entre una interfaz/contrato y su implementación
- Contratos rotos entre funciones/módulos (parámetro agregado en un lado, no en el otro)
- Manejo de errores desparejo (un path tira excepción, otro retorna vacío/null para el mismo caso)
- Mapeos incompletos (campos que existen en el modelo de datos pero no se mapean a la representación de salida o viceversa)

#### 3. Errores conceptuales
- Malinterpretaciones del requerimiento (comparar contra commits/spec/intención)
- Decisiones de arquitectura que no encajan con los patrones del repo (ver CLAUDE.md y AGENTS.md)
- Violaciones de los repo contracts (invariantes de identidad, autorización, colecciones nullable, etc.)
- Uso incorrecto de las bases/abstracciones/utilidades existentes

#### 4. Código muerto o residual
- Código muerto (unreachable, variables sin usar, imports sin usar)
- Código duplicado que debería estar consolidado
- Restos de refactors anteriores (TODO olvidados, parámetros que ya no se usan, funciones vaciadas)
- Archivos nuevos que quedaron a medias

#### 5. Completitud vs requerimiento
- Features pedidas que no se implementaron
- Features implementadas que no se pidieron (scope creep)
- Edge cases del requerimiento no cubiertos

### 1C — Reportar hallazgos del loop

Antes de corregir, listar todos los problemas encontrados en formato:

```
## Loop N — Hallazgos (X problemas)

### Bugs funcionales (N)
- [BUG-1] archivo:linea — descripción breve

### Inconsistencias (N)
- [INC-1] archivo:linea — descripción breve

### Errores conceptuales (N)
- [CON-1] archivo:linea — descripción breve

### Código muerto/residual (N)
- [DEAD-1] archivo:linea — descripción breve

### Completitud (N)
- [COMP-1] descripción — qué falta o sobra
```

Si no hay hallazgos en una categoría, omitirla.

### 1D — Aplicar correcciones

Corregir cada hallazgo uno por uno usando Edit. Después de cada corrección, verificar que no se rompió nada obvio.

**Salvaguardas:**
- No introducir cambios de scope ni "mejoras" que no correspondan a bugs/inconsistencias reales.
- Si dudás si algo es un bug o una preferencia de estilo → **no tocarlo**. Solo corregir problemas objetivos.
- No reformatear código que ya funciona solo porque "podría estar mejor".
- No agregar docstrings, comments, o type annotations que no existían.
- No cambiar patrones que son consistentes con el resto del repo, aunque prefieras otra forma.

### 1E — Correr checks automáticos

Después de las correcciones, correr los checks disponibles:

```bash
# Build
{{BUILD_COMMAND}}

# Si hay tests relevantes al scope, correrlos
{{TEST_COMMAND}}
# (solo si los archivos cambiados están cubiertos por tests)
```

Tratar los fallos de build/test como hallazgos para el siguiente loop.

### 1F — Reporte de cierre del loop

```
## Loop N — Resumen
- Problemas encontrados: X
- Categorías: [bugs: N, inconsistencias: N, conceptuales: N, muerto: N, completitud: N]
- Correcciones aplicadas: X
- Build: OK/FAIL
- Tests: OK/FAIL/SKIPPED
- Loops limpios consecutivos: N
```

## Paso 2 — Condición de terminación

- **Loop termina con 0 hallazgos Y build OK:** incrementar `consecutive_clean`.
- **Loop termina con hallazgos:** resetear `consecutive_clean = 0`.
- **`consecutive_clean == 2`:** convergencia alcanzada → ir al Paso 3.
- **`loop_number == 8`:** máximo alcanzado → ir al Paso 3 con nota de no-convergencia.

## Paso 3 — Reporte final

```
# Auditoría completa

## Resultado
- Estado: CONVERGIDO en loop N / NO CONVERGIDO (máximo 8 loops)
- Loops ejecutados: N
- Total de problemas encontrados: N
- Total de correcciones aplicadas: N

## Problemas más importantes corregidos
1. [categoría] descripción — por qué era importante
2. ...

## Build: OK/FAIL
## Tests: OK/FAIL/SKIPPED

## Si no convergió:
### Problemas persistentes
- descripción — por qué no se estabiliza
```

## Notas

- Esta skill NO toca archivos fuera del alcance determinado en el Paso 0 (salvo interfaces/contratos directamente referenciados).
- NO crea tests (eso es responsabilidad de otras skills).
- NO realiza operaciones bloqueadas por hooks (ej. comandos de cambio de esquema/datos, o ediciones al archivo de secretos/config local protegido).
- Si encuentra un problema que requiere decisión del usuario (ambiguo entre bug y diseño intencional), lo lista y pregunta antes de corregir.
