# Constitución — {{PROYECTO}}

Reglas **no-negociables** del **proceso SDD** que aplican a **toda spec, contrato, plan, tarea e implementación** de este repo. Se asumen siempre; una spec solo declara lo **específico** de su feature.

> Esto **no duplica** `AGENTS.md` ni `CLAUDE.md`. Esos archivos son la verdad operativa (stack, arquitectura, patrones, repo contracts, comandos) y siguen siendo la autoridad técnica. Esta constitución son las reglas duras del **flujo SDD**. Ante conflicto, gana la versión más restrictiva y se pregunta.

---

## 1. Proceso

- **Fase 0 — Investigá y des-ambiguá antes de actuar.** Frente a un prompt, primero reconstruí *qué* quiere el dev y *por qué* (el objetivo, no la solución literal que escribió) e **investigá el contexto** (explorá el repo para entender lo que ya existe). Listá los **supuestos** y toda **ambigüedad del pedido** como preguntas, y resolvelas con el ingeniero humano *antes* de clasificar y de redactar nada. La ambigüedad no resuelta es el defecto más barato de atajar acá — y el más caro si llega al código.
- **Señales de triage (fuente de verdad — el resto de los docs puntean acá).** Va a **SDD completo** si dispara ≥1 de estas señales. Adaptá la lista a tu repo; lo de abajo es la **forma**, no la verdad de tu proyecto:
  - [EJEMPLO — reemplazar] superficie pública nueva o modificada (endpoint/comando/función/evento/schema/campo de un formato de datos)
  - [EJEMPLO — reemplazar] toca autorización/permisos/acceso
  - [EJEMPLO — reemplazar] toca un invariante de datos o de persistencia (unicidad, no-null, integridad referencial, semántica de colecciones)
  - [EJEMPLO — reemplazar] requiere un cambio de esquema/datos (`{{MIGRATION_COMMAND}}`)
  - [EJEMPLO — reemplazar] cambia comportamiento observable que se pueda **expresar como criterio de aceptación** (esto último es una *aclaración* de las señales anteriores, no un gatillo autónomo que arrastre cualquier cambio)

  Va a **ruta rápida** (implementar directo) solo si es **mecánico** y no dispara ninguna señal: rename, typo, formato, copy interno, bump de versión, refactor sin cambio de comportamiento, o un observable evidente sin superficie nueva (p.ej. corregir un mensaje de error o un cálculo obvio). Exploración/auditoría no produce spec ni código; si revela trabajo de feature, se propone abrir una spec. Ops/infra queda fuera salvo que cambie comportamiento observable del producto. **Ante duda de clasificación, es SDD.**
- **Una feature = un `NNN`.** Si un pedido junta varias features, se corta en specs separadas (un `NNN` cada una) y se pregunta el corte. No se mete más de una feature en una sola spec.
- **Ruta rápida ≠ saltar tests.** Salta `/spec`/`/plan`/`/tasks`, no los tests ni los repo contracts: si toca comportamiento testeable (lógica de negocio, autorización, persistencia), el test sigue siendo obligatorio (`CLAUDE.md`).
- **Chequeo de impacto antes de la ruta rápida (obligatorio).** Aun para un fix mecánico, antes de aplicarlo verificá si toca una superficie de un `contract.md` `shipped` o un criterio de aceptación de una spec existente (grepeá `specs/` por la superficie que tocás). Si lo toca → **deja de ser trivial**: es un cambio de contrato → actualizá el `contract.md` (su `status` y la sección correspondiente) y, si tu proyecto expone una interfaz a consumidores, avisá según el flujo de breaking-change. Si no toca nada documentado → ruta rápida.
- **Override del dev / hotfix.** Una instrucción explícita de saltarse el SDD gana: se confirma el trade-off y se procede. Para un hotfix urgente, se implementa el fix **con sus tests** y la spec se registra a posteriori, antes de cerrar con `/verify`.
- **La spec/el contrato mandan.** Si el código diverge de la spec, o la spec está mal → se actualiza la spec/contrato primero, no se improvisa.
- **No se escribe código sin `spec.md` `approved`, `contract.md` `approved` (si tu proyecto expone una interfaz) y `plan.md` aprobado.** Excepción: la ruta rápida del triage (fixes triviales y mecánicos).
- **Nada es "done" sin pasar `/verify`.** Todos los criterios de aceptación ✅ con evidencia (código `archivo:línea` y/o comportamiento ejecutado real). Si un criterio no se puede verificar, estaba mal escrito → reescribirlo.
- **V&V en cada fase, no solo al final (modelo en V).** Cada fase tiene sus **criterios de salida** (su propia V&V) que el ingeniero humano valida antes de avanzar a la siguiente: la spec pasa el **test de ambigüedad** (`requirements-reviewer`) antes de aprobarse; el plan se valida contra los requisitos antes de construir; la descomposición se valida con `/analyze`; la construcción lleva sus tests. Un defecto se ataja **en su fase** — atraparlo en `/verify` cuesta mucho más. Los criterios de salida viven al pie de cada artefacto (`spec.md`, `plan.md`, `tasks.md`, `contract.md`).
- **Gate determinístico (defensa en profundidad).** Los chequeos **objetivos** de esas compuertas —spec `approved`/`done` sin `[VERIFICAR]` abiertos, `approved-by:` poblado, criterios sin tildar, `contract:` que resuelve— los refuerza el validador `/validate-specs` (`.claude/skills/validate-specs/`), corrido a mano y en CI (`.github/workflows/sdd-validation.yml`). No reemplaza el criterio humano ni a `/analyze`: hace **imposible olvidarse** de lo mecánico. La decisión de aprobar queda versionada en el frontmatter (`approved-by:` / `approved-date:`).
- **Cierre proactivo (sin que te lo pidan).** Al terminar cualquier trabajo —incluido un fix por ruta rápida— identificá **vos** qué specs/contracts afecta y reconciliálos: criterios de aceptación tocados, `/verify`, `contract.md` (`status` y la sección de cambios), `INDEX.md`, y el checklist de cierre del `README.md`. El dev no tiene que nombrarte la spec — la encontrás grepeando `specs/`. Trabajar dentro del framework es el default permanente, no algo que el dev declara cada sesión.
- **Preguntá ante CUALQUIER duda de contrato/comportamiento.** Falta un campo, una regla de negocio, una decisión de autorización → preguntá antes de asumir. Todo lo no resuelto va como `[VERIFICAR]` en la spec/contrato y bloquea el paso a `approved`. (El bloqueo duro es para el contenido de la spec; una duda menor de *ruteo* se resuelve con el default conservador = SDD, sin frenar.)
- **Preguntar en cada fase (protocolo `clarify`, no-negociable).** En **cada** paso del flujo (spec, plan, tasks, construcción, verify) se corre el protocolo de preguntas (`.claude/skills/clarify/`): antes de avanzar, la IA convierte en **preguntas** todo lo que asumiría, agrupado por categoría y **con un default sugerido**. El humano contesta, elige una opción, o **delega en la IA**. **Ninguna suposición material es silenciosa**: o la confirma el humano, o queda `[IA-DECIDIÓ]` (default aplicado, registrado y revisable), o `[VERIFICAR]` (sin resolver, bloquea `approved`). Si una fase no tiene preguntas, se declara explícito — no se saltea el paso. Algo que **define el contrato/comportamiento** y el humano no resuelve es `[VERIFICAR]` (bloquea), **no** `[IA-DECIDIÓ]`: no se delega en la IA, sin que el humano lo sepa, una decisión que cambia el contrato.

## 2. Contract-first *(OPCIONAL — solo si tu proyecto expone una interfaz que otros consumen)*

> Esta sección aplica únicamente si tu proyecto expone una **interfaz que otros consumen**: una API, una librería, un CLI, un schema/formato de datos. Si nada externo depende de tu superficie, borrá esta sección (y `/contract`, `contract.md` y el agente `e2e-tester` — ver `GETTING-STARTED.md`).

- La verdad de la superficie pública (endpoints/funciones/comandos/campos/estados) vive en `specs/NNN-*/contract.md` de **este** repo. Quien consuma la interfaz lo **referencia**, no lo re-describe.
- Lifecycle del contrato: `proposed` (en diseño) → `approved` (consensuado, listo para construir) → `shipped` (implementado y desplegable). Un consumidor puede arrancar contra un contrato `proposed`/`approved` marcando `[VERIFICAR]`; **no shipees** un `approved` como si fuera `shipped`. Al pasar a `shipped` corré el checklist de cierre del `README.md`.
- Si una feature **no expone superficie pública** (solo cambia comportamiento interno) → declarálo así en el `contract.md` (o no lo crees); igual documentá la superficie interna si hay algo nuevo relevante.
- La **semántica ambigua de cada campo se declara en el contrato** (ej. zona horaria de una fecha, unidad de una cantidad, encoding de un identificador). Si el contrato no lo dice, vale el default documentado en `AGENTS.md`.

> **OPCIONAL — proyectos multi-repo.** Si la interfaz vive en un repo y sus consumidores en otros, el cruce se hace **por path, no por número**: el campo `consumers:` del contrato apunta a las specs de los consumidores, y la spec del consumidor apunta de vuelta con `contract:`. El `NNN` no significa nada entre repos. Ambos campos deben ser paths que existen, nunca prosa. Ver `README.md`.

## 3. No duplicar — reutilizar la casa natural

- Antes de crear una nueva unidad de código (módulo, clase, servicio, tipo, handler, etc.), **buscá si ya existe** y **extendé la casa natural existente** antes de crear una nueva.
- Si tu repo tiene una abstracción base para un patrón recurrente, **extendela con sus hooks; nunca re-implementes el patrón a mano**.
  - [EJEMPLO — reemplazar] "para una operación CRUD nueva, extender la clase/función base de CRUD del repo (`{{SOURCE_ROOT}}/...`) con sus hooks, en vez de reescribir la lógica de create/update/delete."
- **Simplicidad / anti-complejidad (gate).** La solución debe ser la **más simple** que cumple los criterios de aceptación. Toda complejidad o abstracción nueva (una capa, un wrapper sobre un framework, una dependencia, un patrón) se **justifica explícitamente** contra un criterio — si no, no entra. **Sin features especulativas** ("por si acaso", "capaz después"): solo se construye lo que un criterio pide hoy. Usá los frameworks/librerías **directamente**; envolverlos exige una razón documentada (la desviación va como *complexity tracking* en `plan.md`).
- Solo salteás una tarea si estás **100% seguro** de que ya está hecha y andando. Ante la mínima duda, asumí que falta.
- **Nunca** borres ni pises trabajo existente sin confirmarlo.

## 4. Repo contracts (la autoridad es `AGENTS.md` + `CLAUDE.md`)

Los no-negociables **técnicos** de tu repo viven en `AGENTS.md` (los hechos) y `CLAUDE.md` (la capa de comportamiento). Acá solo listás los de **tu** repo como recordatorio de que se asumen en cada fase y no se repiten en cada spec. Reemplazá los ejemplos por los reales:

- [EJEMPLO — reemplazar] **Errores:** mapeo canónico de error→resultado observable (p.ej. recurso inexistente → `404`/código de error X; violación de regla → `422`/código Y).
- [EJEMPLO — reemplazar] **Autorización:** cómo se protege la superficie y cómo se chequea el permiso (qué decorador/middleware/guard, qué token/claim, qué bypass de admin).
- [EJEMPLO — reemplazar] **Secretos / config:** nunca tocar ni revelar `{{SECRETS_FILE}}`; referirse a settings por nombre de key. Cambios de esquema/datos: nunca correr `{{MIGRATION_COMMAND}}` a mano, proponé el comando y dejá que el dev lo ejecute.

## 5. Tests (obligatorios)

- **Meta-regla:** todo cambio de **comportamiento** lleva tests que lo cubren — los agregás o actualizás en el mismo cambio. Un fix por ruta rápida que toca comportamiento testeable también lleva su test. Si un comportamiento no se puede testear, probablemente esté mal definido.
- La matriz concreta de qué cubrir y cómo nombrar la define tu repo en `AGENTS.md`/`CLAUDE.md`. Lo de abajo es la **forma**:
  - [EJEMPLO — reemplazar] convención de nombres de test del repo (p.ej. `Metodo_ResultadoEsperado_CuandoCondicion`) y categoría/tag obligatorio (unit/integration).
  - [EJEMPLO — reemplazar] superficie protegida → cubrir los escenarios de autorización definidos en `CLAUDE.md` (acceso permitido, denegado, sin credenciales, permiso insuficiente, etc.).
  - [EJEMPLO — reemplazar] patrón CRUD/colección → cubrir create / update / not-found / borde de colección vacía / hooks.
- `/verify` corre `{{TEST_COMMAND}}` y, si tu proyecto expone una interfaz, puede usar el agente `e2e-tester` para validar comportamiento end-to-end real, además de los tests del repo.
- **V&V de requisitos (test de ambigüedad).** Antes de aprobar una spec, el agente `requirements-reviewer` la audita de forma adversarial (ambigüedad, supuestos ocultos, criterios no testeables, casos faltantes). Es la V&V de la fase Requisitos: **el autor de la spec no se valida a sí mismo**. Ver `README.md`.

---

> Ante conflicto entre esta constitución, `AGENTS.md`, `CLAUDE.md` y `specs/README.md`: gana la regla **más restrictiva**, y si siguen en conflicto se **pregunta** antes de proceder. En cuestiones de **proceso SDD** la autoridad final es `specs/README.md`; en cuestiones **técnicas**, `AGENTS.md`.

Estas reglas se asumen en cada fase. Una spec/contrato que las contradiga está mal escrito.
