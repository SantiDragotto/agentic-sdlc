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

> ⚠️ EJEMPLO de referencia — no lo edites; borralo cuando ya entiendas el flujo.

# Marcar ítems como favoritos y ver la lista de favoritos

## 1. Problema / Por qué
Las personas usuarias quieren guardar ítems que les interesan para volver a ellos rápido, sin tener que buscarlos de nuevo. Hoy no hay forma de "recordar" un ítem entre sesiones. Resolverlo da una primera funcionalidad de personalización con muy bajo riesgo, y sirve como ejemplo end-to-end del flujo SDD.

## 2. Comportamiento esperado
El sistema permite a una persona usuaria autenticada marcar un ítem como favorito, quitarlo de favoritos, y listar sus propios favoritos. Cada favorito pertenece a un único usuario; un usuario solo ve y solo puede modificar sus propios favoritos. Marcar un ítem ya marcado no crea un duplicado (operación idempotente). Quitar de favoritos un ítem que no estaba marcado no es un error: el estado final "no es favorito" se cumple igual.

> Los DTOs / formas de payload concretos viven en `contract.md` — acá el comportamiento observable.

### Casos / reglas
| Caso | Condición | Comportamiento esperado |
|---|---|---|
| Marcar | El ítem existe y no estaba en favoritos del usuario | Queda registrado como favorito; aparece en la lista del usuario |
| Marcar idempotente | El ítem ya estaba en favoritos del usuario | No se crea un segundo registro; el estado "favorito" se mantiene |
| Desmarcar | El ítem estaba en favoritos del usuario | Se quita; deja de aparecer en la lista |
| Desmarcar inexistente | El ítem no estaba en favoritos | No falla; el estado final sigue siendo "no favorito" |
| Marcar ítem inexistente | El `itemId` no corresponde a ningún ítem | Rechazo con error de "no encontrado"; no se crea favorito |
| Listar vacío | El usuario no tiene favoritos | Devuelve una lista vacía (no un error) |
| Aislamiento | El usuario A intenta ver o tocar favoritos del usuario B | No puede: solo opera sobre los propios |

## 3. Análisis del problema
> Modelá el problema antes de diseñar la solución (el puente entre el QUÉ y el CÓMO; el diseño concreto va en `plan.md`).
- **Descomposición:** (a) registrar y quitar la relación usuario↔ítem (marcar / desmarcar); (b) listar los favoritos del usuario actual; (c) garantizar que no haya duplicados ni referencias colgadas.
- **Modelo conceptual:** un **Favorito** es una relación **N–N entre Usuario e Ítem** (con la fecha de marcado). Un usuario tiene muchos favoritos; un ítem puede ser favorito de muchos usuarios; **cada par (usuario, ítem) es único**.
- **Impacto:** toca el módulo de **identidad/usuario** (para resolver el usuario actual) y el de **ítems** (para validar que el ítem existe); agrega una unidad de persistencia nueva para la relación. No modifica el catálogo de ítems ni la autenticación.
- **Restricciones / riesgos:** la **idempotencia** (AC5) se garantiza a nivel de datos (unicidad del par), no solo en lógica, para evitar carreras; al **borrar un ítem** se decide qué pasa con sus favoritos (cascada) para no dejar referencias colgadas (AC4).

## 4. Criterios de aceptación  ⭐ (la pieza clave — esto se verifica en /verify)
> Cada criterio: afirmación **testeable** (true/false) sobre el comportamiento observable, sin ambigüedad. Cubrí golden path, bordes (estado vacío, error), **autorización** e **invariantes de persistencia**.

- [x] AC1 — Dado un usuario autenticado y un ítem existente que no tiene marcado, cuando marca el ítem como favorito y luego pide su lista de favoritos, entonces el ítem aparece en la lista. (golden path)
- [x] AC2 — Dado un usuario que tiene un ítem en favoritos, cuando lo desmarca y luego pide su lista, entonces el ítem ya no aparece. (golden path inverso)
- [x] AC3 — Dado un usuario sin favoritos, cuando pide su lista de favoritos, entonces obtiene una lista vacía y no un error; y cuando intenta marcar un `itemId` inexistente, entonces obtiene un error de "no encontrado". (borde: estado vacío / ítem inexistente)
- [x] AC4 — Dado un favorito que pertenece al usuario B, cuando el usuario A intenta verlo o quitarlo, entonces la operación es rechazada y el favorito de B permanece intacto. (autorización)
- [x] AC5 — Dado un usuario que marca el mismo ítem como favorito dos veces seguidas, cuando se consulta la persistencia, entonces existe exactamente un registro de favorito para ese par (usuario, ítem). (invariante de persistencia — idempotencia)

## 5. Contrato producido
La interfaz que esta feature expone está descrita en `./contract.md`. En este ejemplo de un solo repo, la propia UI del proyecto consume ese contrato in-repo.

- Contrato: `./contract.md` (status: `shipped`)
- Operación(es) clave: marcar favorito · desmarcar favorito · listar favoritos del usuario
- Consumido por: la UI del propio proyecto (in-repo). En un proyecto multi-repo, acá iría el path de la(s) spec(s) consumidora(s).

## 6. Fuera de alcance
- Favoritos compartidos entre usuarios o "favoritos públicos".
- Carpetas, etiquetas u orden manual de favoritos.
- Notificaciones cuando un ítem favorito cambia.
- Sincronización offline.

## 7. Preguntas abiertas
- _(ninguna — todas resueltas antes de pasar a `approved`. Si quedara alguna, iría así:)_
- ~~[VERIFICAR] ¿Un usuario puede marcar como favorito un ítem que luego se elimina? Decisión: el favorito se elimina junto con el ítem (cascada). Cerrada.~~

## 8. Notas
- Reutiliza el módulo de usuarios/identidad existente para saber quién es el usuario actual; no introduce un mecanismo de auth nuevo.
- El detalle de diseño (entidad, repositorio, índice único) vive en `plan.md`; acá solo el modelo conceptual (§3).

## 9. Supuestos
- El catálogo de ítems ya existe y expone un `itemId` estable (no cambia para un mismo ítem entre sesiones); esta feature solo lo referencia, no lo administra.
- La identidad del usuario viene del módulo de sesión/identidad existente: el `userId` se deriva siempre del usuario autenticado, nunca llega por el input.
- Existe una capa de persistencia que soporta una restricción de unicidad sobre un par de campos; sin ella AC5 (idempotencia) habría que garantizarla solo en lógica, lo que abre una condición de carrera.

## Criterios de salida (V&V de requisitos)
> El ingeniero humano valida esto ANTES de pasar a Diseño. Atajar un defecto acá cuesta una fracción de atraparlo en /verify.
- [x] Cada criterio de aceptación es **testeable** (true/false, se puede tildar).
- [x] Cubren golden path + bordes (vacío, error, límite) + autorización + invariantes de persistencia.
- [x] **El problema está analizado** (§3: descomposición + modelo conceptual + impacto), no se saltó directo al diseño.
- [x] **Sin alcance especulativo**: cada criterio responde a una necesidad real, no a un 'por si acaso'.
- [x] **0 `[VERIFICAR]`** sin resolver.
- [x] Los **supuestos** están declarados — nada crítico dado por sentado.
- [x] El **alcance** (qué NO entra) está explícito.
- [x] Pasó el **test de ambigüedad** del `requirements-reviewer` sin defectos bloqueantes.
- [x] **Sin suposiciones silenciosas**: cada decisión material de esta fase fue preguntada y quedó resuelta (humano), `[IA-DECIDIÓ]` o `[VERIFICAR]` (protocolo `clarify`).
- [x] El ingeniero humano lo aprobó (`status: approved`).
