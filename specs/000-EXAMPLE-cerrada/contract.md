---
name: 000-favoritos
title: Marcar ítems como favoritos y ver la lista de favoritos
status: shipped          # proposed | approved | shipped
consumers: n/a (un repo — la UI consume el contrato in-repo)
created: 2026-01-15
approved-by: equipo (ejemplo)
approved-date: 2026-01-15
---

> ⚠️ EJEMPLO de referencia — no lo edites; borralo cuando ya entiendas el flujo. Contrato **shipeado** (forma mínima); el mismo, en construcción, está en `../000-EXAMPLE-abierta/`.

# Contrato — Marcar ítems como favoritos y ver la lista de favoritos

## 1. Resumen
Tres operaciones para que el usuario autenticado gestione sus favoritos: marcar, desmarcar y listar los propios. La consume la UI del mismo proyecto. El `userId` nunca viaja en la interfaz: se deriva siempre de la sesión.

## 2. Endpoints
| Método | Ruta | Auth | Request | Response | Códigos |
|---|---|---|---|---|---|
| `POST` | `/favorites` | autenticado | `{ itemId }` | `Favorite` | `201` creado · `200` ya existía (idempotente) · `404` ítem inexistente · `401` |
| `DELETE` | `/favorites/{itemId}` | autenticado | — | vacío | `204` quitado o no estaba (idempotente) · `401` |
| `GET` | `/favorites` | autenticado | — | `Favorite[]` | `200` (lista vacía `[]` si no hay) · `401` |

## 3. DTOs / Modelos

### Request
| Campo | Tipo | Nullable | Semántica |
|---|---|---|---|
| `itemId` | id | no | Ítem a marcar. Debe existir, si no → `404`. Solo en `POST` (en `DELETE` va por ruta). |

El `userId` **no** es un campo del request: se toma de la sesión (AC4).

### Response (`Favorite`)
| Campo | Tipo | Nullable | Notas |
|---|---|---|---|
| `itemId` | id | no | Ítem marcado |
| `userId` | id | no | Dueño del favorito (= usuario actual) |
| `createdAt` | timestamp | no | Cuándo se marcó |

## 4. Entidades / Migraciones
Entidad `Favorite` (`{{SOURCE_ROOT}}/favorites/`), con restricción única sobre `(userId, itemId)` y borrado en cascada al eliminar el ítem.

## 5. Reglas de negocio / Invariantes específicas
- **Idempotencia al marcar (AC5):** marcar un ítem ya marcado devuelve el existente (`200`, no `201`). La garantiza la restricción única en los datos, no un chequeo previo en la lógica: dos pedidos simultáneos no pueden duplicar.
- **Idempotencia al desmarcar:** quitar un ítem que no estaba responde `204`, no `404`: el estado final pedido ya se cumple, y el consumidor no tiene que distinguir casos.
- **Ítem inexistente (AC3):** marcar un `itemId` que no existe → `404`, sin crear favorito.
- **Aislamiento por usuario (AC4):** toda operación se acota al usuario de la sesión.
- **Estado vacío (AC3):** listar sin favoritos devuelve `[]`.
- **Cascada (AC6):** al eliminar un ítem del catálogo se eliminan sus favoritos.

## 6. Estados / enums
_(ninguno)_

## 8. Evidencia
- Tests: `{{SPEC_TEST_COMMAND}}` en verde.
