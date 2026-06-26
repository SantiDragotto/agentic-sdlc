# Instructivo — Cómo trabajar con specs (SDD) en {{PROYECTO}}

> Audiencia: cualquier persona del equipo, con cero contexto previo. El detalle formal del proceso vive en `specs/README.md`; esto es el **paso a paso**. Si en algún momento esto y `specs/README.md` se contradicen, gana `README.md`.

---

## La idea en 60 segundos

Antes, una feature era un MD suelto que se le pasaba a una IA por prompt. El detalle se descartaba, nadie verificaba el final, y las cosas quedaban a medias.

Ahora:

> **La spec versionada en el repo es la fuente de verdad.** Cada feature tiene una carpeta en `specs/` con: qué hace y cómo sabemos que está terminada (`spec.md`), cómo se construye (`plan.md`) y la checklist de trabajo (`tasks.md`). Si tu proyecto expone una interfaz que otros consumen, además lleva la interfaz declarada (`contract.md`). **Nada está "done" hasta recorrer los criterios de aceptación uno por uno con `/verify`.**

Si entendés solo esto, ya entendiste el 80%. El resto es mecánica.

---

## El mapa

**Un repo**, con su carpeta `specs/`. (Si trabajás en varios repos, leé la sección final "Si trabajás en varios repos".)

**Los archivos** (en `specs/`):

| Archivo | Qué es | Cuándo lo tocás |
|---|---|---|
| `NNN-slug/spec.md` | QUÉ hace la feature y POR QUÉ + **criterios de aceptación** | al arrancar una feature |
| `NNN-slug/plan.md` | CÓMO se construye: qué se reutiliza, archivos a tocar, riesgos | después de aprobar la spec |
| `NNN-slug/tasks.md` | checklist atómica; cada tarea atada a un criterio | después de aprobar el plan |
| `NNN-slug/contract.md` | la interfaz que exponés: forma, campos, errores, auth *(OPCIONAL — ver abajo)* | si la feature expone algo que otros consumen |
| `INDEX.md` | catálogo de todas las specs del repo y su estado | siempre que abras o cierres una spec |
| `HALLAZGOS.md` | inbox de bugs/dudas que encontrás usando la app | cuando ves algo raro |
| `CONSTITUTION.md` | reglas duras del repo (no se repiten en cada spec) | la leés una vez; se asume siempre |

> **`contract.md` es OPCIONAL.** Solo aplica si tu proyecto expone una interfaz que otros consumen (una API, una librería, una CLI, un schema/formato de archivo). Si tu proyecto es una app de pantalla cerrada que no le entrega un contrato estable a nadie, ignorá el contrato y el comando `/contract` por completo. `GETTING-STARTED.md` explica cómo borrar esa maquinaria si no la vas a usar.

**Convención de carpeta:** `NNN-slug`, donde `NNN` son 3 dígitos con ceros a la izquierda (`001`, `017`, `120`) y `slug` es kebab-case corto. El número es por repo y solo sirve para ordenar.

---

## El ciclo de una feature, paso a paso

Ejemplo conducido: *"quiero que el usuario pueda marcar ítems como favoritos y ver su lista de favoritos"*. Un solo repo.

### Paso 0 — Triage: ¿esto necesita spec?

Preguntate: **¿cambia comportamiento observable?** (algo nuevo o modificado que el usuario ve · una interfaz que otros consumen · auth/permisos · una migración de esquema o datos).

- **Sí** → seguí este instructivo (es una feature SDD).
- **No** (typo, rename, refactor sin cambio de comportamiento) → ruta rápida: implementá directo, con tests si tocás lógica de negocio. **Pero antes** chequeá que no toque una interfaz ya `shipped` ni un criterio de una spec existente (grepeá `specs/`); si lo toca, dejó de ser trivial.
- **Ante la duda → es SDD.** Las señales completas de triage viven en `CONSTITUTION.md §1` — esa es la fuente única de verdad; el resto de los docs apuntan ahí.

*Nuestro ejemplo: pantalla nueva + persistir el favorito + endpoint o acción nueva → SDD.*

### Paso 1 — Número y carpeta

Mirá el `INDEX.md` del repo y tomá el próximo número libre. Elegí un slug corto.

*Ejemplo: el próximo libre es `001` → `specs/001-items-favoritos/`.*

### Paso 2 — El contrato *(OPCIONAL — solo si exponés una interfaz que otros consumen)*

Si esta feature define o cambia algo que otra cosa consume (una API, una librería pública, una CLI, un formato de archivo), declarálo primero. Tipeás:

```
/contract 001-items-favoritos
```

Qué pasa: Claude explora el repo (qué interfaces ya existen y se pueden reutilizar), redacta `specs/001-items-favoritos/contract.md` desde el template (forma de la interfaz, campos, errores, auth, ¿migración?) y **te pregunta** todo lo que no pueda decidir (`[VERIFICAR]`). Vos respondés. El contrato queda `status: proposed` hasta que esté consensuado, y después `approved`.

*Si tu feature de favoritos es puramente interna a una sola app y no se la entrega a nadie como contrato estable, **saltea este paso** y andá directo al Paso 3.*

### Paso 3 — La spec (QUÉ y POR QUÉ) + el test de ambigüedad

Tipeás:

```
/spec 001-items-favoritos
```

Qué pasa, en tres momentos:

1. **Fase 0 — des-ambiguación del pedido.** Antes de redactar, el `requirements-analyst` (actuando como **analista de requerimientos**) explora lo que ya existe, lista los **supuestos** y las **ambigüedades del pedido**, y te pregunta hasta entender bien el problema.
2. **Redacción** (con el **Análisis del problema**). Crea `spec.md` desde el template: primero el **§3 Análisis del problema** —descompone el problema, modela las entidades/relaciones y el impacto sobre lo existente (el puente entre el QUÉ y el CÓMO, antes de diseñar)— y después los **criterios de aceptación** (ver sección siguiente — es lo más importante de todo el proceso).
3. **V&V de requisitos (test de ambigüedad).** El `requirements-reviewer` (un **revisor de requisitos** independiente) audita la spec buscando ambigüedad, supuestos ocultos, criterios no testeables y casos faltantes, y te devuelve los defectos. El autor no se valida a sí mismo.

No se escribe código. Cuando se cumplen los **criterios de salida** de la spec (al pie del archivo) → `status: approved`. Registrá la fila en el `INDEX.md`.

> ¿Quedaron dudas después de aprobar? Re-corré `/spec` sobre la misma feature (no existe un comando `/clarify`).

### Paso 4 — El plan (CÓMO)

```
/plan 001-items-favoritos
```

Qué pasa: Claude explora el repo a fondo y produce `plan.md`: **qué ya existe y se reutiliza** (regla de oro: no duplicar), cambios por archivo, riesgos. Lo revisás — la pregunta clave es *"¿está reusando lo que ya tenemos?"* — y lo aprobás.

### Paso 5 — Tasks y análisis de consistencia

```
/tasks 001-items-favoritos
/analyze 001-items-favoritos
```

`/tasks` parte el plan en tareas chicas, cada una con su columna "Cubre AC" (qué criterio de aceptación satisface). `/analyze` chequea en frío: ¿todos los criterios tienen tarea? ¿hay tareas que no cubren ningún criterio (scope creep)? Si hay contrato, ¿el plan usa algo que el contrato no declara? Lo que reporte se corrige **antes** de codear.

### Paso 6 — Implementar

Se ejecutan las tareas. **Cada tarea se marca ✅ en `tasks.md` al completarla** — no al final. (Esto no es burocracia: es lo que permite que cualquiera, humano o IA, retome el trabajo sabiendo qué falta.)

### Paso 7 — Verify y cierre (Definition of Done)

```
/verify 001-items-favoritos
```

Qué pasa: se recorre **cada criterio de aceptación** contra el código y la app real, con evidencia (`archivo:línea`). Además de los criterios, corren los gates del proyecto: `{{BUILD_COMMAND}}` y `{{TEST_COMMAND}}`.

- Algún ❌ → la feature **no** está done; se vuelve a implementación con la lista de lo que falta.
- Todos ✅ → `status: done` en la spec, fila del `INDEX.md` actualizada.

Si hay contrato, además pasa a `shipped` con su evidencia (`archivo:línea`).

---

## Cómo escribir un buen criterio de aceptación (lo más importante)

Una afirmación **verdadero/falso** que cualquiera puede verificar mirando la app o pegándole a la interfaz. Si no lo podés tildar, está mal escrito.

✅ **Bien:**
- `Al tocar la estrella en un ítem, queda marcado como favorito y aparece en "Mis favoritos" sin recargar la pantalla.` *(UI, true/false)*
- `Marcar como favorito un ítem que ya no existe devuelve un error claro (no 500) y no agrega nada a la lista.` *(error/borde)*
- `El usuario A no ve ni puede modificar los favoritos del usuario B; pedir la lista de favoritos sin sesión devuelve "no autorizado" y no se ejecuta la lógica.` *(autorización)*
- `Marcar dos veces el mismo ítem lo deja una sola vez en la lista (la operación es idempotente; no se persisten duplicados).` *(invariante de persistencia)*

❌ **Mal:** `La pantalla de favoritos funciona bien.` · `Manejar correctamente los permisos.` · `Mejorar la UX.`

Tips: formato **"Dado … cuando … entonces …"** o afirmación concreta sobre lo que se ve/pasa. Cubrí los bordes: estado vacío, error, autorización, datos históricos. Si persistís algo, declará el invariante (qué se conserva, qué se ignora, qué no se duplica).

---

## FAQ

**¿Para un fix de una línea también?** Lo decide el **triage** (paso 0). Mecánico sin señal → ruta rápida (con tests si tocás lógica de negocio, y chequeo de impacto antes). Dispara una señal → SDD aunque sea "una línea". Ante duda → SDD.

**¿Y si es urgente / quiero ir sin ceremonia?** Una instrucción explícita del dev gana: se confirma el trade-off y se procede. Hotfix: se implementa con tests y la spec se registra a posteriori, antes de cerrar con `/verify`. El gate es el default, no una jaula.

**¿Tengo que decirle a Claude que use SDD?** No. El `CLAUDE.md` del repo carga el gate en cada sesión: Claude clasifica tu pedido, te propone la ruta y, al cerrar cualquier trabajo, reconcilia por su cuenta las specs (y el contrato, si hay) que tocó: criterios, `status`, `INDEX.md`.

**¿Tengo que usar la IA para esto?** No. Los `/comandos` son atajos para Claude Code, pero el proceso vale igual a mano. Lo importante son los criterios de aceptación y verificarlos.

**¿Necesito el contrato?** Solo si tu proyecto expone una interfaz que otros consumen (API, librería, CLI, schema/formato). Si no, ignorá `/contract`, `contract.md` y el agente `e2e-tester`; `GETTING-STARTED.md` explica cómo borrarlos.

**¿Qué es el "test de ambigüedad"?** Es la V&V de la fase Requisitos: antes de aprobar la spec, el agente `requirements-reviewer` la revisa de forma adversarial (términos vagos, supuestos no declarados, criterios que no se pueden tildar, casos faltantes). Atrapa el defecto en la spec, que es donde más barato sale arreglarlo — no en el código. El autor de la spec (`requirements-analyst`) no se valida a sí mismo: por eso son dos agentes con dos roles.

**¿Por qué me hace preguntas en cada paso?** Es el protocolo `clarify` (`.claude/skills/clarify/`), y es a propósito. En **cada fase** (spec, plan, tasks, construcción, verify), antes de avanzar, la IA toma todo lo que de otro modo asumiría en silencio y te lo devuelve como **preguntas** —agrupadas por tema y cada una con un **default sugerido**. Tenés tres salidas por pregunta: la **contestás** vos, **aceptás el default**, o le decís **"decidí vos"** (la IA aplica el default y lo deja marcado `[IA-DECIDIÓ]` — queda registrado y lo podés revisar después; no frena nada). Lo que **no** resolvés queda `[VERIFICAR]` y **bloquea** la aprobación de la fase. Lo que define el contrato o el comportamiento no se delega: eso va sí o sí como pregunta tuya o `[VERIFICAR]`. El punto no es interrogarte: es que **ninguna decisión de la IA sea invisible** — vos seguís decidiendo, incluso cuando delegás. Si una fase no tiene nada que preguntar, te lo dice y avanza.

**¿Por qué cada agente "actúa como" un rol?** Porque el oficio cambia según la fase: quien escribe requisitos piensa como analista de requerimientos; quien diseña, como arquitecto; quien construye, como ingeniero sénior; quien verifica, como ingeniero de V&V. La IA produce en cada paso; **las decisiones importantes las tomás vos** (aprobás cada compuerta). Eso es lo que hace que el kit sirva para construir en serio, no solo para "vibecodear mejor".

**¿Dónde anoto un bug que encontré probando?** `specs/HALLAZGOS.md`. Una línea alcanza; el triage es después. **No lo arregles a ciegas ni lo pierdas.**

**¿Dónde está el detalle formal del proceso?** `specs/README.md` (canónico). Este instructivo es el cómo-se-hace.

---

## Si trabajás en varios repos (OPCIONAL — proyectos multi-repo)

> Saltá esta sección entera si tu proyecto es un solo repo. Toda la maquinaria de abajo solo aplica cuando una interfaz vive en un repo (el **dueño del contrato**) y la consumen otros (los **consumidores**) — por ejemplo un backend y uno o más frontends, o una librería y sus apps cliente.

Cada repo tiene su propia carpeta `specs/` y su propia numeración. **La numeración no significa nada entre repos:** la misma feature puede ser `017` en un repo y `024` en otro. El cruce se hace por **path**: la spec del consumidor tiene un campo `contract:` apuntando al `contract.md` real del dueño, y el contrato tiene `consumers:` apuntando a las specs que lo consumen. *Si el path no existe, el campo está mal.*

### El handshake del contrato, contado como conversación

```
DUEÑO:        "Diseñé la interfaz de favoritos" ......... contract.md status: proposed
CONSUMIDOR:   "Le falta el campo isFavorite en la
               respuesta del listado" ................... [VERIFICAR] en su spec / comentario
DUEÑO:        "Listo, agregado. ¿Cerramos así?" ......... edita el contract
CONSUMIDOR:   "Cerrado." ................................ status: approved  ← construyen en paralelo
DUEÑO:        "Implementado, con evidencia" ............. status: shipped (archivo:línea)
CONSUMIDOR:   consume la interfaz real, corre /verify ... su spec: done
```

- `proposed` = puede cambiar; el consumidor arranca bajo su propio riesgo marcando `[VERIFICAR]`.
- `approved` = consensuado; estable para construir en paralelo. **Todavía no existe del lado del dueño.**
- `shipped` = implementado con evidencia. Recién acá el consumidor lo da por hecho.
- El token de estado es **una palabra**; matices después de un guion (`shipped — falta deploy a prod`). Nunca uses "shipped parcial" queriendo decir dos cosas.

### Los canales (la verdad durable vive en archivos versionados)

El chat (Slack/WhatsApp) es para el nudge ("shipié el contrato de favoritos, fijate"); el detalle queda en el repo:

| Canal | Dirección | Para qué |
|---|---|---|
| `contract.md` + su `status` | dueño → consumidores | El handshake formal |
| `docs/pendientes-*.md` *(en cada consumidor)* | consumidor → dueño | "Necesito esto y no existe". El dueño lo triaja → fila `proposed` en su `INDEX.md` → `/contract` |
| `INDEX.md` del dueño | dueño → todos | El único lugar que responde "¿qué le debe el dueño a los consumidores hoy?" |
| `specs/HALLAZGOS.md` *(en cada repo)* | quien testea → el equipo | Bugs/dudas antes de que sean spec |

> Si te encontrás escribiendo un MD suelto para avisarle algo al otro repo, pará: editá el artefacto versionado que corresponde (el contrato, el `INDEX.md`, o el archivo de pendientes).

### Checklist "al shipear un contrato" (dueño, obligatorio)

Al pasar un `contract.md` a `shipped` (o cambiar uno ya `shipped`):

- [ ] `status: shipped` + Evidencia (`archivo:línea`, commit/PR)
- [ ] Fila del `INDEX.md` del dueño actualizada
- [ ] **Por cada path en `consumers:`**: editar la spec consumidora (los `[VERIFICAR]` que este contrato responde)
- [ ] Cerrar los items del `pendientes-*.md` del consumidor que este contrato resuelve
- [ ] Breaking change sobre un `shipped` → avisar al equipo consumidor **antes** de mergear, y acordar ventana/compatibilidad

### Escenarios del día a día

1. **Feature en dueño + consumidor** → el handshake de arriba. Contrato primero, specs en paralelo, cada lado su `/verify`.
2. **Solo consumidor** (cambio local, sin interfaz nueva) → `contract: n/a`; el dueño ni se entera.
3. **Solo dueño** (sin consumidor todavía) → igual lleva spec; `consumers: n/a`.
4. **El consumidor necesita algo que el dueño no shipeó** → `[VERIFICAR]` en su spec + entrada en su `pendientes-*.md`. **Nunca inventa la interfaz.** No queda bloqueado: deja el empty state / mock y sigue.
5. **El dueño cambia un contrato ya `shipped`** (breaking) → vuelve a `proposed`/`approved`, se avisa a cada consumidor **antes** de mergear, se acuerda ventana/compatibilidad. Nada se shipea sin que el consumidor sepa.
