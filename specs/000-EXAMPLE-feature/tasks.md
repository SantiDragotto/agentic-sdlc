---
name: 000-favoritos
spec: ./spec.md
plan: ./plan.md
---

> ⚠️ EJEMPLO de referencia — no lo edites; borralo cuando ya entiendas el flujo.

# Tareas — Marcar ítems como favoritos y ver la lista de favoritos

> Checklist atómica derivada del plan, en orden de ejecución. Cada tarea referencia el/los criterio(s) de aceptación que ayuda a cumplir (trazabilidad para `/analyze` y `/verify`).

| # | Tarea | Archivo(s) | Cubre AC | Dep. | Estado |
|---|---|---|---|---|---|
| 1 | Crear la entidad `Favorite { userId, itemId, createdAt }` con unicidad en `(userId, itemId)` | `{{SOURCE_ROOT}}/favorites/favorite.<ext>` | AC5 | `[P]` | ✅ |
| 2 | Crear el repositorio de favoritos: `add` (insertar-si-no-existe), `remove`, `listByUser` | `{{SOURCE_ROOT}}/favorites/favorites_repository.<ext>` | AC1, AC2, AC5 | 1 | ✅ |
| 3 | Crear el servicio: derivar usuario actual, validar que el `itemId` existe, orquestar add/remove/list | `{{SOURCE_ROOT}}/favorites/favorites_service.<ext>` | AC1, AC2, AC3, AC4 | 2 | ✅ |
| 4 | Exponer las operaciones marcar / desmarcar / listar (ver `contract.md`) | `{{SOURCE_ROOT}}/routes/favorites.<ext>` | AC1, AC2, AC3 | 3 | ✅ |
| 5 | Listar siempre acotado al usuario actual; nunca aceptar `userId` del input | `{{SOURCE_ROOT}}/favorites/favorites_service.<ext>` | AC4 | 3 | ✅ |
| 6 | Aplicar el cambio de persistencia (índice único) — proponer `{{MIGRATION_COMMAND}}`, no ejecutarlo | (persistencia) | AC5 | 1 | ✅ |
| 7 | Test: marcar un ítem → aparece en la lista; desmarcar → desaparece | `{{SOURCE_ROOT}}/favorites/favorites.test.<ext>` | AC1, AC2 | 4 | ✅ |
| 8 | Test: lista vacía devuelve `[]`; marcar `itemId` inexistente → "no encontrado" | `{{SOURCE_ROOT}}/favorites/favorites.test.<ext>` | AC3 | 4 | ✅ |
| 9 | Test: usuario A no ve ni puede quitar el favorito del usuario B; el de B queda intacto | `{{SOURCE_ROOT}}/favorites/favorites.test.<ext>` | AC4 | 5 | ✅ |
| 10 | Test: marcar dos veces el mismo ítem → exactamente un registro persistido | `{{SOURCE_ROOT}}/favorites/favorites.test.<ext>` | AC5 | 2 | ✅ |

Estados: ☐ pendiente · ◐ en progreso · ✅ hecha
Dep.: número(s) de tarea prerequisito, o `[P]` si la tarea puede correr en paralelo con sus hermanas (sin dependencias entre sí).

## Cobertura
> Toda fila de criterios de aceptación de la spec debe aparecer en al menos una tarea. Toda tarea debe mapear a un AC (si no, es scope creep → justificar o sacar). Esto lo chequea `/analyze`.

- AC1 → tareas 2, 3, 4, 7
- AC2 → tareas 2, 3, 4, 7
- AC3 → tareas 3, 4, 8
- AC4 → tareas 3, 5, 9
- AC5 → tareas 1, 2, 6, 10

Todos los AC están cubiertos y toda tarea mapea a al menos un AC. ✅

## Tests obligatorios (no omitir — ver CLAUDE.md > Testing Standards)
- [x] **Golden path** cubierto: marcar y desmarcar reflejan en la lista (tarea 7 → AC1, AC2).
- [x] **Bordes** cubiertos: estado vacío e ítem inexistente (tarea 8 → AC3).
- [x] **Autorización** cubierta: aislamiento entre usuarios (tarea 9 → AC4).
- [x] **Invariante de persistencia** cubierto: idempotencia / sin duplicados (tarea 10 → AC5).

[EJEMPLO — reemplazar] Si tu proyecto tiene reglas de test propias (categorías/traits, escenarios de auth obligatorios, etc.), listalas acá y mapealas a AC igual que arriba.

## Criterios de salida (V&V de la descomposición)
> Se valida con /analyze ANTES de implementar.
- [x] Cada criterio de aceptación está cubierto por ≥1 tarea (columna 'Cubre AC').
- [x] Ninguna tarea huérfana (toda tarea mapea a un AC, o se justifica).
- [x] Las tareas de test obligatorias están incluidas.
- [x] `/analyze` corrió y no quedan inconsistencias sin resolver.
