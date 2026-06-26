---
name: 000-favoritos
spec: ./spec.md
contract: ./contract.md
status: approved         # draft | approved
approved-by: equipo (ejemplo)
approved-date: 2026-01-15
---

> ⚠️ EJEMPLO de referencia — no lo edites; borralo cuando ya entiendas el flujo.

# Plan — Marcar ítems como favoritos y ver la lista de favoritos

> El CÓMO. Se genera tras `spec.md` en `approved` (y `contract.md` en `approved` si toca la interfaz). Lo aprobás vos antes de implementar.
> **Regla de oro:** reutilizar/extender lo que ya existe antes que crear (CONSTITUTION §3).

## 1. Enfoque técnico
Se modela "favorito" como una relación entre el usuario actual y un ítem. Se agrega una unidad de persistencia para esa relación con una restricción de unicidad sobre el par `(usuario, ítem)`, lo que garantiza la idempotencia (AC5) a nivel de datos en vez de en la lógica. La identidad del usuario se toma del módulo de identidad existente (nunca se recibe el `userId` por parámetro de entrada: se deriva de la sesión autenticada), lo que da el aislamiento entre usuarios (AC4) "gratis". Se exponen tres operaciones — marcar, desmarcar, listar — siguiendo el mismo patrón que el resto de las operaciones de escritura/lectura del proyecto.

## 2. Qué ya existe y se reutiliza
> Resultado de explorar el repo. Componentes existentes que esta feature usa o extiende, con su path **neutro de ejemplo**. Evita duplicación.

| Existe | Path | Se reutiliza / extiende |
|---|---|---|
| Módulo de identidad / usuario actual | `{{SOURCE_ROOT}}/auth/` | Para resolver el usuario autenticado y autorizar; no se crea auth nueva |
| Modelo/almacén de ítems | `{{SOURCE_ROOT}}/items/` | Para validar que el `itemId` existe antes de marcar |
| Punto de entrada de la API/UI | `{{SOURCE_ROOT}}/routes/` (o equivalente) | Se agregan las 3 operaciones siguiendo el patrón existente |
| Capa de acceso a datos | `{{SOURCE_ROOT}}/data/` | Se agrega un repositorio/colección de favoritos reusando el patrón vigente |

## 3. Cambios por archivo
| Archivo | Capa | Acción (crear/editar) | Qué |
|---|---|---|---|
| `{{SOURCE_ROOT}}/favorites/favorite.<ext>` | Modelo / entidad | crear | Entidad `Favorite { userId, itemId, createdAt }` con unicidad en `(userId, itemId)` |
| `{{SOURCE_ROOT}}/favorites/favorites_repository.<ext>` | Acceso a datos | crear | `add` (idempotente), `remove`, `listByUser` |
| `{{SOURCE_ROOT}}/favorites/favorites_service.<ext>` | Lógica / servicio | crear | Orquesta: valida ítem, deriva usuario actual, llama al repositorio |
| `{{SOURCE_ROOT}}/routes/favorites.<ext>` | API / UI | crear | Expone marcar / desmarcar / listar (ver `contract.md`) |
| `{{SOURCE_ROOT}}/items/...` | Modelo de ítems | editar | (Opcional) cascada: al borrar un ítem, borrar sus favoritos |

> Capas (nombres **neutros de ejemplo** — adaptá a tu stack): entrada/API · lógica/servicio · modelo/entidad · acceso a datos · mapeo. Tu proyecto puede tener menos capas.

## 4. Datos / persistencia
Se persiste una colección/tabla `favorites` con `userId`, `itemId`, `createdAt` y una **restricción de unicidad sobre `(userId, itemId)`** (clave para AC5). La operación de marcar es un "insertar si no existe": ante violación de unicidad, se trata como éxito (idempotente), no como error. Listar filtra siempre por el `userId` del usuario actual.

Si tu stack requiere un cambio de esquema, **proponé** el comando (no lo ejecutes — lo corre la persona dev):

```
{{MIGRATION_COMMAND}}   # ej. crear tabla/colección favorites + índice único (userId, itemId)
```

## 5. Autorización
- **Marcar / desmarcar / listar**: requieren usuario autenticado. El `userId` SIEMPRE se deriva de la sesión, nunca se acepta del input.
- No hay forma de pasar el `userId` de otra persona: por construcción, un usuario solo puede operar sobre sus propios favoritos (AC4). No hace falta un chequeo de "dueño" adicional porque la consulta ya está acotada al usuario actual.

[EJEMPLO — reemplazar] Si en tu proyecto la autorización fuera por permiso/rol explícito, acá listarías: `marcar → permiso items.write` · `listar → permiso items.read`, etc.

## 6. Tests
- **Golden path (AC1, AC2)**: marcar → aparece en la lista; desmarcar → desaparece.
- **Bordes (AC3)**: lista vacía devuelve `[]` (no error); marcar `itemId` inexistente → "no encontrado".
- **Autorización (AC4)**: el usuario A no ve ni puede quitar un favorito del usuario B; el de B queda intacto.
- **Invariante de persistencia (AC5)**: marcar dos veces el mismo ítem → existe exactamente un registro.
- Idempotencia de desmarcar: quitar algo no marcado no falla.

[EJEMPLO — reemplazar] Nombres y framework de test según tu stack ({{TEST_COMMAND}}). Mantené un caso por criterio de aceptación para que `/verify` pueda mapear test ↔ AC.

## 7. Riesgos / decisiones
> **Trazabilidad + complexity tracking:** ligá cada decisión técnica y dependencia nueva al/los criterio(s) que la justifican; toda desviación de la opción más simple (una abstracción/capa/dependencia extra) va documentada acá con su porqué.

- **Idempotencia**: garantizarla por restricción de unicidad en la base, no solo por un `if` en código, evita carreras (dos requests casi simultáneos). Decisión tomada.
- **Cascada al borrar ítem**: se decide borrar los favoritos asociados cuando se elimina un ítem, para no dejar referencias colgadas. Bajo impacto.
- **Performance de listar**: con índice sobre `userId` el listado es barato; no se prevé paginación en esta primera versión (fuera de alcance).

## Criterios de salida (V&V de diseño)
> El ingeniero humano valida esto ANTES de pasar a Construcción.
- [x] Cada criterio de aceptación de la spec tiene un enfoque en el plan.
- [x] **Simplicidad**: es el diseño más simple que cumple los criterios; toda complejidad/abstracción/dependencia nueva está justificada contra un criterio (sin sobre-ingeniería).
- [x] Se **reutiliza** lo existente donde corresponde (no se duplica).
- [x] Persistencia/datos y autorización están contemplados.
- [x] Riesgos identificados con su mitigación.
- [x] **Sin suposiciones silenciosas**: cada decisión material de esta fase fue preguntada y quedó resuelta (humano), `[IA-DECIDIÓ]` o `[VERIFICAR]` (protocolo `clarify`).
- [x] El ingeniero humano aprobó el plan (`status: approved`).
