---
name: NNN-slug
spec: ./spec.md
contract: ./contract.md
status: draft            # draft | approved
approved-by: <quién aprobó el plan — al pasar a approved>
approved-date: <YYYY-MM-DD>
---

# Plan — <Título de la feature>

> El CÓMO. Se genera tras `spec.md` en `approved` (y `contract.md` en `approved` si la feature expone una interfaz). Lo aprobás vos antes de implementar.
> **Regla de oro:** reutilizar/extender lo que ya existe antes que crear (ver CONSTITUTION §3).

## 1. Enfoque técnico
<2-5 líneas: la estrategia. ¿Extiende un módulo/clase base existente o crea uno nuevo? ¿Qué patrón de `AGENTS.md` se sigue? Por qué.>

## 2. Qué ya existe y se reutiliza
<Resultado de explorar el repo. Componentes/funciones/módulos/modelos existentes que esta feature usa o extiende, con su path. Evita duplicación.>

| Existe | Path | Se reutiliza / extiende |
|---|---|---|
| | | |

## 3. Cambios por archivo
| Archivo | Capa / área | Acción (crear/editar) | Qué |
|---|---|---|---|
| | | | |

> **Capa / área:** describila en los términos de TU arquitectura (ver `AGENTS.md`). [EJEMPLO — reemplazar] interfaz/entrada (handlers, UI, CLI) · lógica de negocio (servicios, casos de uso) · acceso a datos (repos, queries) · modelos/tipos · mapeo/transformación.

## 4. Datos / persistencia
<Cómo se leen/escriben los datos (la abstracción de acceso que use el proyecto — repos, store, ORM — nunca acceso crudo si hay una capa por encima). Entidades/tablas/colecciones nuevas o modificadas. ¿Cambia el esquema? Si sí, PROPONÉ el comando (no lo ejecutes — lo corre el dev):>

```
{{MIGRATION_COMMAND}}
```

## 5. Autorización
<Por operación: qué permiso/rol/scope se exige y cómo se chequea. ¿Punto de control nuevo? (mantené la lógica de autorización fuera del cuerpo de la operación; centralizala). Documentá acá las reglas transversales que apliquen — ej. jerarquías de permisos, bypass de admin — para no repetirlas en cada test.>

## 6. Tests
<Qué cubrir y dónde. Toda operación protegida → escenarios de autorización (ver tasks.md). Operación que persiste → invariantes de integridad de datos. Convención de nombres de tests del proyecto (ver `AGENTS.md`/`CLAUDE.md`).>

## 7. Riesgos / decisiones
> **Trazabilidad + complexity tracking:** ligá cada decisión técnica y dependencia nueva al/los criterio(s) que la justifican; toda desviación de la opción más simple (una abstracción/capa/dependencia extra) va documentada acá con su porqué.
> **Decisiones delegadas a la IA:** las que el dev delegó (protocolo `clarify`) quedan registradas acá como `[IA-DECIDIÓ] <decisión> — default aplicado, revisable` (no bloquean, pero son visibles y revisables).

- <riesgo o trade-off, y cómo se maneja. Versión de runtime/lenguaje del repo (ver `AGENTS.md`) si usás APIs nuevas. Impacto sobre cache, rendimiento o concurrencia si aplica.>

## Criterios de salida (V&V de diseño)
> El ingeniero humano valida esto ANTES de pasar a Construcción.
- [ ] Cada criterio de aceptación de la spec tiene un enfoque en el plan.
- [ ] **Simplicidad**: es el diseño más simple que cumple los criterios; toda complejidad/abstracción/dependencia nueva está justificada contra un criterio (sin sobre-ingeniería).
- [ ] Se **reutiliza** lo existente donde corresponde (no se duplica).
- [ ] Persistencia/datos y autorización están contemplados.
- [ ] Riesgos identificados con su mitigación.
- [ ] **Sin suposiciones silenciosas**: cada decisión material de esta fase fue preguntada y quedó resuelta (humano), `[IA-DECIDIÓ]` o `[VERIFICAR]` (protocolo `clarify`).
- [ ] El ingeniero humano aprobó el plan (`status: approved`).
