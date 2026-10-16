---
name: 000-favoritos
spec: ./spec.md
plan: ./plan.md
---

> ⚠️ EJEMPLO de referencia — no lo edites; borralo cuando ya entiendas el flujo. Es la checklist **a mitad de construcción**: se borra al cerrar la spec (mirá `../000-EXAMPLE-cerrada/`).

# Tareas — Marcar ítems como favoritos y ver la lista de favoritos

> Checklist atómica derivada del plan, en orden de ejecución. Cada tarea referencia el/los criterio(s) de aceptación que ayuda a cumplir (trazabilidad para `/analyze` y `/verify`). Se tilda cada tarea al completarla, no todas al final.

| # | Tarea | Archivo(s) | Cubre AC | Test (ancla `Spec`/`AC`) | Dep. | Estado |
|---|---|---|---|---|---|---|
| 1 | Crear la entidad `Favorite { userId, itemId, createdAt }` con unicidad en `(userId, itemId)` | `{{SOURCE_ROOT}}/favorites/favorite.<ext>` | AC5 | — | `[P]` | ✅ |
| 2 | Crear el repositorio de favoritos: `add` (insertar-si-no-existe), `remove`, `listByUser` | `{{SOURCE_ROOT}}/favorites/favorites_repository.<ext>` | AC1, AC2, AC5 | — | 1 | ✅ |
| 3 | Crear el servicio: derivar usuario actual, validar que el `itemId` existe, orquestar add/remove/list | `{{SOURCE_ROOT}}/favorites/favorites_service.<ext>` | AC1, AC2, AC3, AC4 | — | 2 | ✅ |
| 4 | Exponer las operaciones marcar / desmarcar / listar (ver `contract.md`) | `{{SOURCE_ROOT}}/routes/favorites.<ext>` | AC1, AC2, AC3 | — | 3 | ✅ |
| 5 | Listar siempre acotado al usuario actual; nunca aceptar `userId` del input | `{{SOURCE_ROOT}}/favorites/favorites_service.<ext>` | AC4 | — | 3 | ✅ |
| 6 | Cascada: al borrar un ítem, borrar sus favoritos | `{{SOURCE_ROOT}}/items/...` | AC6 | — | 1 | ✅ |
| 7 | Aplicar el cambio de persistencia (índice único + cascada) — proponer `{{MIGRATION_COMMAND}}`, no ejecutarlo | (persistencia) | AC5, AC6 | — | 1, 6 | ✅ |
| 8 | Test: marcar un ítem → aparece en la lista; desmarcar → desaparece (y desmarcar uno no marcado no falla) | `{{SOURCE_ROOT}}/favorites/favorites.test.<ext>` | AC1, AC2 | `Spec=000`, `AC=AC1` · `AC=AC2` | 4 | ✅ |
| 9 | Test: lista vacía devuelve `[]`; marcar `itemId` inexistente → "no encontrado" | `{{SOURCE_ROOT}}/favorites/favorites.test.<ext>` | AC3 | `Spec=000`, `AC=AC3` | 4 | ✅ |
| 10 | Test: usuario A no ve ni puede quitar el favorito del usuario B; el de B queda intacto | `{{SOURCE_ROOT}}/favorites/favorites.test.<ext>` | AC4 | `Spec=000`, `AC=AC4` | 5 | ◐ |
| 11 | Test: marcar dos veces el mismo ítem → exactamente un registro persistido | `{{SOURCE_ROOT}}/favorites/favorites.test.<ext>` | AC5 | `Spec=000`, `AC=AC5` | 2 | ☐ |
| 12 | Test: borrar un ítem marcado → ninguna lista lo devuelve, sin registros colgados | `{{SOURCE_ROOT}}/favorites/favorites.test.<ext>` | AC6 | `Spec=000`, `AC=AC6` | 6 | ☐ |

Estados: ☐ pendiente · ◐ en progreso · ✅ hecha
Dep.: número(s) de tarea prerequisito, o `[P]` si la tarea puede correr en paralelo con sus hermanas (sin dependencias entre sí).
Test: el ancla que lleva el test que escribe la tarea, o `—` si la tarea no escribe un test.

## Cobertura
> Toda fila de criterios de aceptación de la spec debe aparecer en al menos una tarea. Toda tarea debe mapear a un AC (si no, es scope creep → justificar o sacar). Esto lo chequea `/analyze`.

- AC1 → tareas 2, 3, 4, 8
- AC2 → tareas 2, 3, 4, 8
- AC3 → tareas 3, 4, 9
- AC4 → tareas 3, 5, 10
- AC5 → tareas 1, 2, 7, 11
- AC6 → tareas 6, 7, 12

Todos los AC están cubiertos, cada uno con al menos una tarea de test anclada, y toda tarea mapea a al menos un AC. ✅

## Tests obligatorios (no omitir — ver CLAUDE.md > Testing Standards)
> Todo test que cubre un criterio **nace** con su ancla `Spec`/`AC`; no se ancla después.
- [x] **Golden path** cubierto: marcar y desmarcar reflejan en la lista (tarea 8 → AC1, AC2).
- [x] **Bordes** cubiertos: estado vacío e ítem inexistente (tarea 9 → AC3).
- [x] **Autorización** cubierta: aislamiento entre usuarios (tarea 10 → AC4).
- [x] **Invariantes de persistencia** cubiertos: idempotencia (tarea 11 → AC5) y sin referencias colgadas (tarea 12 → AC6).

[EJEMPLO — reemplazar] Si tu proyecto tiene reglas de test propias (categorías/traits, escenarios de auth obligatorios, etc.), listalas acá y mapealas a AC igual que arriba.

## Criterios de salida (V&V de la descomposición)
> Se valida con /analyze ANTES de implementar.
- [x] Cada criterio de aceptación está cubierto por ≥1 tarea (columna 'Cubre AC').
- [x] Ninguna tarea huérfana (toda tarea mapea a un AC, o se justifica).
- [x] Las tareas de test obligatorias están incluidas, cada una con su ancla `Spec`/`AC`.
- [x] `/analyze` corrió y no quedan inconsistencias sin resolver.
