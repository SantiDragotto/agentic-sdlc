# Hallazgos — {{PROYECTO}} (inbox)

> Acá anotamos lo que encontramos **usando / testeando la app**: bugs, errores, mejoras, dudas. Es el paso previo a SDD: así no se pierde nada y no se arregla "a ciegas". Una línea por hallazgo; después se **triaja**.
>
> **OPCIONAL — proyectos multi-repo:** si tenés varios repos, el inbox existe en cada uno (mismo formato) y cada uno anota lo que observa en su propia app. Si el hallazgo es del **otro** repo, anotalo igual y movelo / avisá al equipo dueño.

## Cómo se usa

1. **Anotá apenas lo ves** (no esperes a terminar de testear): fecha, quién, dónde, tipo, severidad y una descripción **tildable** (qué viste, no "anda mal").
2. **Triajá** (cuando se agarra el hallazgo): cada uno termina en una de estas salidas y se marca el estado:
   - `fix-trivial` — mecánico, sin superficie nueva (alcance canónico en `CONSTITUTION.md §1`) → se arregla al toque, **sin spec** (linkeá el commit si querés). **Antes, chequeá impacto:** si toca una regla/comportamiento cubierto por un AC de una spec —o (OPCIONAL, si tu proyecto expone una interfaz) un campo/método/endpoint de un `contract.md` `shipped`— deja de ser trivial → es cambio de contrato (ajustá el `contract.md` y avisá a cada consumer de su `consumers:`).
   - `→ spec NNN` — **cambia comportamiento observable** (lógica de negocio, estado nuevo, regla) → se abre una spec (`/spec NNN-slug`) o se agrega un **criterio de aceptación** a una existente.
   - `→ backlog` — falta algo que todavía no se diseñó → entra al **Backlog** de `INDEX.md` como `proposed` y se promueve a feature con `/spec` (o `/contract`) cuando se retome.
   - `descartado` — no aplica / no se hace (con motivo).
3. Cuando un hallazgo se cierra, dejalo con su salida (**no lo borres** — sirve de historial).

## Tipos y severidad

- **Tipo:** `bug` · `error` · `mejora` · `duda`
- **Severidad:** `alta` (rompe / bloquea) · `media` (molesta, hay workaround) · `baja` (cosmético / nice-to-have)

## Inbox

| Fecha | Quién | Dónde (pantalla / componente) | Tipo | Sev | Descripción (qué viste) | Triage / salida | Estado |
|---|---|---|---|---|---|---|---|
| AAAA-MM-DD | _ejemplo_ | [EJEMPLO — reemplazar] pantalla / módulo donde lo viste | duda | baja | Descripción tildable de qué observaste (no "anda mal") | salida del triage + link a spec/commit si aplica | ✅ cerrado |
|  |  |  |  |  |  |  | ☐ |

Estados: ☐ nuevo · ◐ en triage · ✅ cerrado

> Las **señales de triage** (qué es trivial vs. qué cambia comportamiento observable) son fuente única de verdad en `CONSTITUTION.md §1`. Ante duda, gana la regla más restrictiva y se pregunta.

## Herramientas que ayudan a encontrar/cerrar hallazgos

- **`/verify`** (+ agente `validator`) — recorrer los criterios de aceptación de una spec contra la app real.
- **`e2e-tester`** (OPCIONAL) — probar la interfaz expuesta (API/CLI/librería) de punta a punta y dejar log persistente (golden/edge/auth), solo si tu proyecto expone una.
