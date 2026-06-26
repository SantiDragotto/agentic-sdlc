---
name: NNN-slug
title: <título corto de la feature>
status: proposed         # proposed | approved | shipped
consumers: <quién consume esta interfaz — otra spec, otra app, otro repo — o "n/a (solo interno)">
created: <YYYY-MM-DD>
approved-by: <quién aprobó — al pasar a approved/shipped; trazabilidad de la decisión humana>
approved-date: <YYYY-MM-DD>
---

> OPCIONAL — solo si esta feature expone una interfaz que otros consumen (API, librería, CLI, schema/formato). Si no, borrá este archivo.

# Contrato — <Título de la feature>

> **Fuente de verdad de la interfaz** que expone esta feature. El consumidor la REFERENCIA, no la re-describe.
> Lifecycle: `proposed` (en diseño) → `approved` (consensuado, listo para construir) → `shipped` (implementado y desplegable).
> Las reglas transversales (generación de IDs, autorización, forma del wrapper de respuesta, mapeo error→código de estado) se asumen de `CONSTITUTION.md`; acá solo lo **específico** de la feature.

## 1. Resumen
<2-4 líneas: qué expone esta feature a nivel interfaz y quién la consume.>

## 2. Interfaz / Operaciones
> Una fila por operación que expone la feature. Sea API HTTP, función de librería, subcomando de CLI o evento — describí método/operación, qué entra, qué sale, qué autorización exige y qué errores puede devolver.

| Método / Operación | Identificador (ruta / firma / comando) | Auth | Entrada | Salida | Errores |
|---|---|---|---|---|---|
| | | | | | |

> **Auth:** indicá el permiso/rol/scope requerido, o `público`. Las reglas generales de autorización viven en `CONSTITUTION.md`.
> **Salida:** respetá el formato de respuesta estándar del proyecto (ver `AGENTS.md`). [EJEMPLO — reemplazar] una creación devuelve el recurso creado y un código "creado".

## 3. Modelos de entrada / salida

### Entrada
| Campo | Tipo | Nullable / opcional | Semántica |
|---|---|---|---|
| | | | |

> Convenciones de la feature sobre los campos de entrada. [EJEMPLO — reemplazar] colecciones opcionales: ausente = "no enviado, mantener" · vacío = "vaciar" · con valores = "reemplazar". Identificador del recurso en una creación: **se ignora** si viene del cliente (lo genera el sistema). Campos inmutables: declarar cuáles nunca se pueden editar.

### Salida
| Campo | Tipo | Nullable / opcional | Notas |
|---|---|---|---|
| | | | |

## 4. Cambios de esquema / datos
<Entidades, tablas, columnas o estructuras nuevas/modificadas. Indicá si necesita un cambio de esquema o migración de datos. Si sí, PROPONÉ el comando (no lo ejecutes — lo corre el dev):>

```
{{MIGRATION_COMMAND}}
```

## 5. Reglas de negocio / Invariantes específicas
- <regla concreta de esta feature: validaciones (→ error de validación), recurso inexistente (→ not-found), efectos colaterales, cascadas… Lo que el consumidor necesita saber para usar la interfaz sin sorpresas.>

## 6. Estados / enums
<Enums nuevos o estados relevantes con sus valores y significado.>

## 7. Pendientes / decisiones abiertas
- [VERIFICAR] <decisión sin cerrar — bloquea pasar de `proposed` a `approved`>

## 8. Evidencia (completar cuando status = shipped)
<`archivo:línea` del código real que implementa cada operación. Esto vuelve el contrato un as-built verificable y alimenta `/verify`.>

- `<operación …>` → `<archivo>:<línea>`

## Criterios de salida (V&V de la interfaz)
> El ingeniero humano valida esto ANTES de construir contra el contrato.
- [ ] Cada operación declara entrada, salida, autorización y errores.
- [ ] Consistente con el comportamiento de la spec (sin contradicciones).
- [ ] **0 `[VERIFICAR]`** sin resolver.
- [ ] (Multi-repo) los consumidores en `consumers:` están avisados.
- [ ] El ingeniero humano aprobó (`status: approved`).
