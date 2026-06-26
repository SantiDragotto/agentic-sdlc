---
name: NNN-slug
title: <título corto de la feature>
status: draft            # draft | approved | in-progress | done | superseded
contract: <./contract.md, o "n/a (no expone interfaz nueva)">
supersedes: <NNN o vacío — spec vieja que ESTA reemplaza>
superseded-by: <NNN o vacío — spec que reemplaza a ESTA>
created: <YYYY-MM-DD>
approved-by: <quién aprobó — se completa al pasar a approved; trazabilidad de la decisión humana>
approved-date: <YYYY-MM-DD — al aprobar>
---

# <Título de la feature>

## 1. Problema / Por qué
<2-4 líneas: qué necesidad o dolor resuelve. Para quién. Por qué ahora.>

## 2. Comportamiento esperado
<Qué hace el sistema de forma observable: qué operaciones/comandos/pantallas aparecen o cambian, reglas de negocio, validaciones, efectos sobre los datos. Los modelos/payloads concretos (si los hay) viven en contract.md — acá el comportamiento, no la forma exacta de los datos.>

### Casos / reglas
| Caso | Condición | Comportamiento esperado |
|---|---|---|
| | | |

## 3. Análisis del problema
> Modelá el **problema** antes de diseñar la solución — es el puente entre el QUÉ y el CÓMO (el diseño concreto va en `plan.md`). Para una feature trivial puede ser breve, pero no se salta.
- **Descomposición:** en qué sub-problemas o partes se divide.
- **Modelo conceptual:** las entidades/conceptos clave y sus relaciones (qué cosas existen y cómo se vinculan), **sin** implementación.
- **Impacto:** qué partes del sistema existente toca (a alto nivel; el detalle por archivo es del plan).
- **Restricciones / riesgos:** lo que condiciona la solución o pone en riesgo el resultado, detectado **antes** de diseñar.

## 4. Criterios de aceptación  ⭐ (la pieza clave — esto se verifica en /verify)
> Cada criterio: afirmación **testeable** (true/false) sobre el comportamiento del sistema, sin ambigüedad. Cubrí golden path, bordes (estado vacío, error), **autorización** e **invariantes de persistencia** (lo que tiene que seguir siendo cierto sobre los datos).

[EJEMPLO — reemplazar]
- [ ] AC1 (golden path) — Dado un usuario autenticado, cuando marca un ítem como favorito, entonces el ítem queda en su lista de favoritos.
- [ ] AC2 (borde/error) — Dado un ítem que ya está en favoritos, cuando se vuelve a marcar como favorito, entonces no se duplica y la operación es idempotente.
- [ ] AC3 (autorización) — Dado un usuario A, cuando intenta leer o modificar la lista de favoritos del usuario B, entonces la operación es rechazada.
- [ ] AC4 (invariante de persistencia) — Dado un ítem que se elimina del catálogo, cuando se consulta cualquier lista de favoritos, entonces no aparecen referencias colgadas a ese ítem.

## 5. Contrato producido
> OPCIONAL — solo si esta feature expone una interfaz que otros consumen (API, librería, CLI, schema/formato). Si no, poné `contract: n/a` en el frontmatter y borrá esta sección.

<Link a ./contract.md y la interfaz clave que esta feature define. Quién la consume.>

- Contrato: `./contract.md` (status: <proposed | approved | shipped>)
- Interfaz clave: `…`
- Consumido por: <quién lo usa | n/a>

## 6. Fuera de alcance
<Qué explícitamente NO entra, para no expandir scope.>

## 7. Preguntas abiertas
> Las dudas sin resolver van `[VERIFICAR]` (bloquean pasar a `approved`); las que el dev delegó en la IA van `[IA-DECIDIÓ] <decisión> — default aplicado, revisable` (no bloquean, quedan registradas). Ver protocolo `clarify`.
- [VERIFICAR] <pregunta sin resolver — bloquea pasar a `approved`>

## 8. Notas
<Decisiones de diseño, reuso de algo existente, dependencias con otras specs.>

## 9. Supuestos
<Lo que se da por cierto y hay que validar. Un supuesto no validado es un defecto latente — el `requirements-reviewer` los caza.>

## Criterios de salida (V&V de requisitos)
> El ingeniero humano valida esto ANTES de pasar a Diseño. Atajar un defecto acá cuesta una fracción de atraparlo en /verify.
- [ ] Cada criterio de aceptación es **testeable** (true/false, se puede tildar).
- [ ] Cubren golden path + bordes (vacío, error, límite) + autorización + invariantes de persistencia.
- [ ] **El problema está analizado** (§3: descomposición + modelo conceptual + impacto), no se saltó directo al diseño.
- [ ] **Sin alcance especulativo**: cada criterio responde a una necesidad real, no a un 'por si acaso'.
- [ ] **0 `[VERIFICAR]`** sin resolver.
- [ ] Los **supuestos** están declarados — nada crítico dado por sentado.
- [ ] El **alcance** (qué NO entra) está explícito.
- [ ] Pasó el **test de ambigüedad** del `requirements-reviewer` sin defectos bloqueantes.
- [ ] **Sin suposiciones silenciosas**: cada decisión material de esta fase fue preguntada y quedó resuelta (humano), `[IA-DECIDIÓ]` o `[VERIFICAR]` (protocolo `clarify`).
- [ ] El ingeniero humano lo aprobó (`status: approved`).
