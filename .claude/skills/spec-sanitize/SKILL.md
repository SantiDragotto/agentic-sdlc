---
name: spec-sanitize
description: Compacta UNA spec done a la forma mínima (spec.md = problema + comportamiento + criterios; contract.md = la interfaz con la §8 en una línea) sin perder un invariante ni romper las citas del código. Borra el proceso (plan.md, tasks.md, andamio de la spec), reescribe las decisiones como reglas y, con los AC anclados a tests, poda lo que ya dicen el código y los tests. Una spec por invocación. Invocar con "/spec-sanitize NNN", "compactá la spec NNN", "limpiá las specs cerradas"; /verify la corre con --cierre sobre la spec que cierra.
argument-hint: "<NNN> [--cierre | --anclar]"
---

# spec-sanitize — compactar UNA spec a la forma mínima

Argumentos: `$ARGUMENTS`

Una spec cerrada describe el sistema, no cómo se construyó (`specs/CONSTITUTION.md §6`). Se lee muchas más veces de las que se escribe: cada sesión que la carga paga sus tokens. Esta skill lleva una spec `done` a la forma mínima: lo que queda es lo que alguien va a **preguntar** dentro de un año; lo que cuenta lo que **pasó** se va. La historia queda en git y no se linkea.

Dos entradas, mismos pasos:

- **Cierre** (`--cierre`): la corre `/verify` sobre la spec que acaba de pasar a `done`.
- **Stock** (`/spec-sanitize NNN`): una spec `done` vieja que todavía carga proceso (típico al adoptar esta regla sobre un corpus existente).

Lo que cambia con `--cierre` está dicho en cada paso.

## La regla que gobierna todo

Cada bloque de texto es una de tres cosas:

| Qué es | Ejemplo | Qué pasa |
|---|---|---|
| **Regla o criterio** (el *qué*) | «quitar un favorito inexistente responde éxito» | queda; se condensa solo con los AC anclados (Paso 3) |
| **Decisión** (el *porqué* donde sorprende) | «éxito y no not-found: el estado final pedido ya se cumple» | se reescribe como regla de la spec (§2) o del contrato (§5): qué + por qué + qué se descartó, sin fecha ni narrativa |
| **Proceso** (cómo se llegó) | diario, preguntas cerradas o tachadas, «34/34 tests», `archivo:línea`, notas al plan, criterios de salida | se borra |

Si un bloque no entra en ninguna, es un hallazgo para el reporte: **no lo borres**.

## De a una, nunca en lote

Una spec por invocación. Un lote de specs en un solo diff no lo revisa nadie y choca con trabajo en vuelo. Los barridos del stock los orquesta el hilo principal: una spec por vez (o un subagente por spec), commit por lote chico.

---

## Paso 0 — Precondiciones (si una falla, FRENÁ y decí cuál)

```bash
NNN=<el número>
ls -d specs/${NNN}-*/                         # existe, y UNA sola carpeta
grep -m1 '^status:' specs/${NNN}-*/spec.md    # done
git status --porcelain -- specs/${NNN}-*      # vacío (solo stock)
```

Dry-run del borrado (el runner que corresponda a tu entorno):

```
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/skills/spec-sanitize/compact-spec.ps1 -Spec <NNN>
sh .claude/skills/spec-sanitize/compact-spec.sh --spec <NNN>
```

- Número duplicado en dos carpetas → frená: renumerar rompe las citas (y en multi-repo, los `contract:` de los consumidores).
- Carpeta de ejemplo (`*-EXAMPLE-*`) → frená: es material de referencia, no se compacta.
- Salteada por **churn** (commits de trabajo en los últimos 14 días; el mantenimiento del corpus no cuenta) → frená: se procesa cuando sale de la ventana. Es la protección del trabajo en vuelo de otros.
- Con `--cierre` no aplican el árbol limpio ni el churn: los cambios sin commitear y el trabajo reciente son los de la propia feature. El número único sí, y el `status: done` ya lo puso `/verify`.

## Paso 1 — Inventario

```bash
wc -c specs/${NNN}-*/*.md                                   # peso ANTES
grep -n '^## \|^### ' specs/${NNN}-*/spec.md specs/${NNN}-*/contract.md   # el mapa
git log --diff-filter=A --format=%as -- specs/${NNN}-*/spec.md | tail -1  # edad
```

- **Rótulos citados** (§, AC, reglas con ID) desde el código, los tests y otras specs: esos **no se renumeran ni desaparecen** sin corregir la cita.
  ```bash
  grep -rnE "[Ss]pecs? 0*${NNN}\b" --exclude-dir=.git --exclude-dir=specs .   # código, tests, docs
  grep -rnE "\b0*${NNN}\b[^\n]{0,12}§ ?[0-9]" specs | grep -v "^specs/${NNN}-"   # otras specs
  ```
- **Anclas:** por cada AC de la spec, ¿algún test lo cita (`CONSTITUTION.md §5`)? Usá la forma del ancla de `AGENTS.md > Testing`. Anotá **anclados / total**: con todos anclados la spec habilita la poda profunda.

No leas los archivos enteros de una: sacá el mapa y leé por sección.

## Paso 2 — Borrar el proceso (archivos)

```
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/skills/spec-sanitize/compact-spec.ps1 -Spec <NNN> -Execute
sh .claude/skills/spec-sanitize/compact-spec.sh --spec <NNN> --execute
```

Con `--cierre`, agregá `-Closing` / `--closing`: saltea el churn y borra `plan.md`/`tasks.md` aunque tengan cambios sin commitear (las tareas tildadas).

Borra todo `.md` de la carpeta salvo `spec.md` y `contract.md` (con `git rm`; lo nunca commiteado, del disco). No borra un archivo que se cita por path desde fuera de `specs/` (código, `.claude/`, docs): lo lista y frena esa spec. Los links que quedarían colgando desde otras specs se listan para sacarlos en el Paso 3.

## Paso 3 — Reescribir a la forma mínima

**`spec.md`** queda con: §1 Problema · §2 Comportamiento (reglas y tabla de casos) · §4 Criterios · §6 Fuera de alcance (solo si evita un malentendido). Salen: §3 Análisis del problema (lo que describa una regla del sistema pasa a §2), §5 Contrato producido (el `contract:` del frontmatter ya apunta), §7 Preguntas (lo que decidieron va como regla en §2 o criterio en §4), §8 Notas, §9 Supuestos (los que condicionan el comportamiento, como regla en §2), los criterios de salida, las notas del template y cualquier `archivo:línea`, conteo o log de exploración. El frontmatter queda entero (`approved-by:` es trazabilidad de la decisión humana).

**`contract.md`** queda con: §1 Resumen · §2 Interfaz · §3 Modelos · §4 Esquema/datos · §5 Reglas · §6 Estados · §8 Evidencia = `- Tests: \`{{SPEC_TEST_COMMAND}}\` en verde.` Salen: §7 Pendientes (cada decisión viva pasa a §5 como regla: qué + por qué + qué se descartó, sin fecha), la evidencia vieja (anclas, corridas, commits), los criterios de salida y los avisos de proceso.

Reglas duras de la reescritura:

- **No se renumeran** secciones ni criterios, ni se mueve o renombra la carpeta: el código, los tests y otras specs los citan. Las secciones que salen dejan su número libre.
- **Los rótulos citados se conservan.** Si lo citado desaparece, corregí la cita donde esté (solo el comentario en el código; la cita en la otra spec): apuntala a donde vive ahora la regla, o sacala si ya no existe en ningún lado.
- **Si la spec o el contrato describen algo que el código ya no hace**, no lo "arreglás" en silencio: lo anotás para el humano. La divergencia es un bug o un texto stale, y cuál de los dos es decisión humana.
- **Lo que no tiene test que lo ancle, no se condensa:** con anclas incompletas solo se borra proceso; las reglas y los criterios quedan enteros.
- Nada de links a historia: ni archivos borrados, ni commits, ni tags.

### Poda profunda — solo con todos los AC anclados

Con `--cierre` corre siempre: `/verify` llega con cada AC citado por un test en verde. En el stock, solo si el Paso 1 dio todos los AC anclados.

Con el ancla en verde, el test es la versión ejecutable del criterio y la copia del código solo puede mentir. Tres preguntas, en orden:

1. **¿Lo dice el código o el test?** → puntero, no copia. Una tabla campo por campo de una entidad se vuelve «entidad `X` (`<módulo>`)» más solo las filas con una regla propia (una unicidad, un default).
2. **¿Alguien lo va a preguntar, o cuenta lo que pasó?** → lo primero queda, lo segundo se va.
3. **¿Se entiende sin el `plan.md`?** → si no, quedó huérfano: reescribilo o sacalo.

Los criterios anclados se condensan a una línea (ID + qué afirma). La interfaz, los modelos y las reglas del contrato **no se parten**: son lo que el consumidor referencia.

## Paso 4 — Anclar (opt-in: `--anclar`)

Si las anclas están incompletas y querés la poda profunda, leé [`anclar.md`](./anclar.md): primero se busca el test que ya existe y se le agrega el ancla. Toca tests: va en un commit aparte de la compactación. Con `--cierre` no aplica.

## Paso 5 — Verificar (todo tiene que dar bien)

```bash
ls specs/${NNN}-*/                          # solo spec.md y contract.md
grep -nE '\.[a-z]{1,5}:[0-9]+\b|[0-9]+ ?/ ?[0-9]+ tests?|~~\[VERIFICAR' specs/${NNN}-*/*.md   # vacío
grep -oE '\bAC[0-9]+\b' specs/${NNN}-*/spec.md | sort -u                  # los mismos IDs que antes
wc -c specs/${NNN}-*/*.md                   # peso DESPUÉS
```

Y `/validate-specs`: 0 errores, y sin el WARN de proceso para esta spec.

Contestá leyendo **solo lo que quedó**: ¿qué hace y qué le promete al consumidor? ¿por qué es así donde sorprende? ¿cómo sé que anda (`{{SPEC_TEST_COMMAND}}`)? Si alguna no se contesta, podaste de más: revertí esa parte.

## Paso 6 — Reporte

```
spec <NNN>-<slug> — compactada
  Proceso      borrados: <archivos> · secciones: <§3, §5, §7…>
  Reescrito    spec.md <antes> → <después> KB · contract.md <antes> → <después> KB
  Decisiones   <n> reescritas como reglas (spec §2 / contract §5)
  Poda prof.   <aplicó | no aplicó: n AC sin anclar>
  Citas        <comentarios y specs reapuntados: archivo — rótulo viejo → nuevo | ninguna>
  Para el humano
  - <bloques que no entraron en ninguna categoría, divergencias spec↔código, AC sin test>
```

Si no hay nada para el humano, escribí `sin hallazgos`.

## Lo que esta skill NUNCA hace

- No corre en lote, ni sobre una spec que no esté `done`, ni sobre un ejemplo, ni en la ventana de churn salvo con `--cierre`.
- No renumera secciones, AC ni carpetas, ni mueve el `contract.md`.
- No condensa una regla o un criterio sin todos los AC anclados.
- No toca código de producción: solo comentarios que citan un rótulo que cambió, y los tests con `--anclar`.
- No commitea: el commit lo hace el hilo principal.
