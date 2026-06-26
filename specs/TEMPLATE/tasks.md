---
name: NNN-slug
spec: ./spec.md
plan: ./plan.md
---

# Tareas — <Título de la feature>

> Checklist atómica derivada del plan, en orden de ejecución. Cada tarea referencia el/los criterio(s) de aceptación que ayuda a cumplir (trazabilidad para `/analyze` y `/verify`).

| # | Tarea | Archivo(s) | Cubre AC | Dep. | Estado |
|---|---|---|---|---|---|
| 1 | | | AC1 | | ☐ |
| 2 | | | AC2 | | ☐ |
| 3 | | | | | ☐ |

Estados: ☐ pendiente · ◐ en progreso · ✅ hecha
Dep.: número(s) de tarea prerequisito, o `[P]` si la tarea puede correr en paralelo con sus hermanas (sin dependencias entre sí).

## Cobertura
> Toda fila de criterios de aceptación de la spec debe aparecer en al menos una tarea. Toda tarea debe mapear a un AC (si no, es scope creep → justificar o sacar). Esto lo chequea `/analyze`.

## Tests obligatorios (no omitir — ver CLAUDE.md > Testing Standards)
> Adaptá estas categorías a tu stack y a las reglas transversales de tu `CONSTITUTION.md`. Lo importante es la cobertura, no la sintaxis.

[EJEMPLO — reemplazar]
- [ ] **Escenarios de autorización** si la operación está protegida: enumerá y cubrí cada caso relevante — permiso válido✔ · sin credenciales✗ · credencial del tipo equivocado✗ · permiso insuficiente✗ · falta el scope/tenant✗ · bypass de admin✔ · comparación case-insensitive si corresponde✔ · formato malformado✗.
- [ ] **Invariantes de integridad** si la feature persiste datos: el identificador del recurso lo genera el sistema (no se acepta del cliente) · al actualizar se preserva la identidad del registro existente · not-found en leer/actualizar/eliminar un recurso inexistente · los hooks/efectos colaterales declarados se disparan.
- [ ] **Categorización de tests**: etiquetá cada test como unitario o de integración según la convención del proyecto. En tests de integración: asertá tanto el resultado externo (código/estado/respuesta) **como** que, en caso de rechazo por autorización, la lógica de negocio **no** se ejecutó.

## Criterios de salida (V&V de la descomposición)
> Se valida con /analyze ANTES de implementar.
- [ ] Cada criterio de aceptación está cubierto por ≥1 tarea (columna 'Cubre AC').
- [ ] Ninguna tarea huérfana (toda tarea mapea a un AC, o se justifica).
- [ ] Las tareas de test obligatorias están incluidas.
- [ ] `/analyze` corrió y no quedan inconsistencias sin resolver.
