---
name: 000-favoritos
title: Marcar ítems como favoritos y ver la lista de favoritos
status: done             # draft | approved | in-progress | done | superseded
contract: ./contract.md
supersedes:
superseded-by:
created: 2026-01-15
approved-by: equipo (ejemplo)
approved-date: 2026-01-15
---

> ⚠️ EJEMPLO de referencia — no lo edites; borralo cuando ya entiendas el flujo. Es la feature **cerrada** (forma mínima); la misma, a mitad de construcción, está en `../000-EXAMPLE-abierta/`.

# Marcar ítems como favoritos y ver la lista de favoritos

## 1. Problema / Por qué
Las personas usuarias quieren guardar ítems que les interesan para volver a ellos rápido, sin tener que buscarlos de nuevo. Hoy no hay forma de "recordar" un ítem entre sesiones.

## 2. Comportamiento esperado
Una persona usuaria autenticada marca un ítem como favorito, lo quita y lista los propios. Cada favorito pertenece a un único usuario, que es el único que lo ve y lo modifica. La interfaz está en `contract.md`.

### Casos / reglas
| Caso | Condición | Comportamiento esperado |
|---|---|---|
| Marcar | El ítem existe y no estaba en favoritos del usuario | Queda registrado; aparece en la lista del usuario |
| Marcar idempotente | El ítem ya estaba en favoritos del usuario | No se crea un segundo registro |
| Desmarcar | El ítem estaba en favoritos del usuario | Se quita; deja de aparecer en la lista |
| Desmarcar inexistente | El ítem no estaba en favoritos | No falla: el estado final "no favorito" ya se cumple |
| Marcar ítem inexistente | El `itemId` no corresponde a ningún ítem | Error "no encontrado"; no se crea favorito |
| Listar vacío | El usuario no tiene favoritos | Lista vacía, no un error |
| Aislamiento | El usuario A intenta ver o tocar favoritos del usuario B | No puede: solo opera sobre los propios |
| Ítem eliminado | El ítem se borra del catálogo | Sus favoritos se borran con él (cascada) |

## 4. Criterios de aceptación
- [x] AC1 — marcar un ítem existente lo agrega a la lista del usuario.
- [x] AC2 — desmarcarlo lo saca de la lista.
- [x] AC3 — sin favoritos, la lista es vacía (no error); marcar un `itemId` inexistente da "no encontrado".
- [x] AC4 — un usuario no puede ver ni quitar el favorito de otro; el del otro queda intacto.
- [x] AC5 — marcar dos veces el mismo ítem deja exactamente un registro para el par (usuario, ítem).
- [x] AC6 — borrar un ítem del catálogo no deja favoritos que lo referencien.

## 6. Fuera de alcance
- Favoritos compartidos o públicos, carpetas/etiquetas/orden manual, notificaciones de cambios, sincronización offline.
