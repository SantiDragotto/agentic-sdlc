---
name: 000-favoritos
title: Marcar ítems como favoritos y ver la lista de favoritos
status: shipped          # proposed | approved | shipped
consumers: n/a (un repo — la UI consume el contrato in-repo)
created: 2026-01-15
approved-by: equipo (ejemplo)
approved-date: 2026-01-15
---

> ⚠️ EJEMPLO de referencia — no lo edites; borralo cuando ya entiendas el flujo.

> **OPCIONAL — solo si tu proyecto expone una interfaz que otros consumen (API, librería, CLI, schema/formato).**
> Este ejemplo **SÍ** expone una interfaz (3 operaciones HTTP). Si tu proyecto no expone nada a un consumidor externo, **borrá `contract.md`** y poné `contract: n/a` en el frontmatter de `spec.md`.

# Contrato — Marcar ítems como favoritos y ver la lista de favoritos

> **Fuente de verdad de la interfaz** de esta feature. El consumidor la REFERENCIA, no la re-describe.
> Lifecycle: `proposed` (en diseño) → `approved` (consensuado, listo para construir) → `shipped` (implementado y desplegable).
> Las reglas transversales (forma de IDs, auth, colecciones nullable, envoltura de respuesta, errores→códigos) se asumen de `CONSTITUTION.md`; acá solo lo **específico** de la feature.

## 1. Resumen
Expone tres operaciones para que el usuario autenticado gestione sus favoritos: marcar un ítem, desmarcarlo y listar los propios. En este ejemplo de un repo, la consume la UI del mismo proyecto. El `userId` nunca viaja en la interfaz: se deriva siempre de la sesión.

## 2. Endpoints
| Método | Ruta | Auth | Request | Response | Códigos |
|---|---|---|---|---|---|
| `POST` | `/favorites` | autenticado | `{ itemId }` | `Favorite` | `201` creado · `200` ya existía (idempotente) · `404` ítem inexistente · `401` |
| `DELETE` | `/favorites/{itemId}` | autenticado | — | vacío | `204` quitado o no estaba (idempotente) · `401` |
| `GET` | `/favorites` | autenticado | — | `Favorite[]` | `200` (lista vacía `[]` si no hay) · `401` |

> **Auth (neutro de ejemplo):** las tres requieren usuario autenticado; el dueño se deriva de la sesión, no del input. Adaptá a tu esquema (permiso/rol/token) si corresponde.
> **Response:** forma de envoltura de respuesta según tu proyecto (ej. una envoltura `{ data, success, message }` u objeto plano). Acá se muestra el payload "desnudo".

## 3. DTOs / Modelos

### Request
| Campo | Tipo | Nullable | Semántica |
|---|---|---|---|
| `itemId` | id | no | Ítem a marcar como favorito. Debe existir, si no → `404`. Solo en `POST` (en `DELETE` va por ruta). |

> El `userId` **no** es un campo del request: se toma de la sesión autenticada (invariante de autorización, AC4).

### Response (`Favorite`)
| Campo | Tipo | Nullable | Notas |
|---|---|---|---|
| `itemId` | id | no | Ítem marcado |
| `userId` | id | no | Dueño del favorito (= usuario actual) |
| `createdAt` | timestamp | no | Cuándo se marcó |

## 4. Entidades / Migraciones
Entidad nueva `Favorite { userId, itemId, createdAt }` con **índice/restricción único sobre `(userId, itemId)`** (garantiza idempotencia, AC5). Si tu stack necesita un cambio de esquema, **proponé** el comando (no lo ejecutes — lo corre la persona dev):

```
{{MIGRATION_COMMAND}}   # ej. crear tabla/colección favorites + índice único (userId, itemId)
```

## 5. Reglas de negocio / Invariantes específicas
- **Idempotencia al marcar (AC5):** marcar un ítem ya marcado NO crea un segundo registro; devuelve el existente (`200` en vez de `201`).
- **Idempotencia al desmarcar:** quitar un ítem que no estaba en favoritos NO es error (`204`); el estado final "no favorito" se cumple igual.
- **Ítem inexistente (AC3):** marcar un `itemId` que no existe → `404`, no se crea favorito.
- **Aislamiento por usuario (AC4):** toda operación se acota al usuario de la sesión; no se puede leer ni tocar el favorito de otra persona.
- **Estado vacío (AC3):** listar sin favoritos devuelve `[]`, nunca un error.

## 6. Estados / enums
_(ninguno — esta feature no introduce enums ni máquina de estados.)_

## 7. Pendientes / decisiones abiertas
- _(ninguna — todas cerradas antes de `approved`. Si quedara una, iría así:)_
- ~~[VERIFICAR] ¿`DELETE` sobre un favorito inexistente devuelve `204` o `404`? Decisión: `204` (idempotente). Cerrada.~~

## 8. Evidencia (completar cuando status = shipped)
> `archivo:línea` reales que implementan cada operación. Esto vuelve el contrato un as-built verificable y alimenta `/verify`. (Paths de ejemplo — neutros y ficticios.)

- `POST /favorites` → `{{SOURCE_ROOT}}/routes/favorites.<ext>:24` → servicio `{{SOURCE_ROOT}}/favorites/favorites_service.<ext>:18` (`add`)
- `DELETE /favorites/{itemId}` → `{{SOURCE_ROOT}}/routes/favorites.<ext>:41` → servicio `favorites_service.<ext>:33` (`remove`)
- `GET /favorites` → `{{SOURCE_ROOT}}/routes/favorites.<ext>:12` → servicio `favorites_service.<ext>:9` (`listByUser`)
- Entidad + índice único `(userId, itemId)` → `{{SOURCE_ROOT}}/favorites/favorite.<ext>:7`
- Tests → `{{SOURCE_ROOT}}/favorites/favorites.test.<ext>` (AC1–AC5)

## Criterios de salida (V&V de la interfaz)
> El ingeniero humano valida esto ANTES de construir contra el contrato.
- [x] Cada operación declara entrada, salida, autorización y errores.
- [x] Consistente con el comportamiento de la spec (sin contradicciones).
- [x] **0 `[VERIFICAR]`** sin resolver.
- [x] (Multi-repo) los consumidores en `consumers:` están avisados.
- [x] El ingeniero humano aprobó (`status: approved`).
