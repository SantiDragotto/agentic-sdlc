---
name: clarify
description: Protocolo de preguntas que se corre en CADA fase del SDD (spec, plan, tasks, construcción, verify) para evitar suposiciones silenciosas de la IA. Antes de avanzar de fase, surface como preguntas todo lo que la IA asumiría, agrupado por categoría y con un default sugerido; el humano contesta, elige, o delega en la IA (y queda registrado). Auto-trigger: cualquier fase del flujo, "preguntá antes de asumir", "no asumas", "qué decisiones estás tomando", "clarificá". Lo invocan los comandos y los agentes.
argument-hint: "[fase: spec | plan | tasks | build | verify]"
allowed-tools: Read, Grep, Glob
---

# /clarify — preguntar en cada paso, nunca asumir en silencio

Argumentos: `$ARGUMENTS`

Este es el **protocolo de preguntas** del kit. Su regla de oro: **ninguna suposición material de la IA es silenciosa**. En cada fase, antes de avanzar, la IA convierte en **preguntas** todo lo que estaría por asumir, y el ingeniero humano decide — o delega esa decisión en la IA, pero **siempre queda registrado quién decidió**.

Se corre en **todas** las fases (lo invocan `/spec`, `/plan`, `/tasks`, la construcción y `/verify`, y los agentes de cada etapa). No es opcional: si una fase no tiene preguntas, se **declara explícito** ("sin ambigüedades en esta fase") — no se saltea el paso.

## Por qué

El error más caro del desarrollo asistido por IA es la **suposición plausible pero equivocada**: la IA elige algo razonable sin preguntar, y el defecto se descubre tarde. Este protocolo lo ataja en su fase (shift-left): hace **visible** cada decisión y deja que el humano —que conoce el sistema— la tome o la delegue a conciencia.

## Los dos marcadores

| Marcador | Significado | ¿Bloquea? |
|---|---|---|
| `[VERIFICAR]` | Pregunta abierta **sin resolver**. Falta una decisión que el humano debe tomar. | **Sí** — bloquea pasar a `approved`. |
| `[IA-DECIDIÓ]` | El humano **delegó** la decisión; la IA aplicó el **default** sugerido. Queda registrado y es **revisable**. | No, pero es **visible** (el validador lo cuenta como recordatorio). |

> La diferencia clave: una decisión de la IA **nunca es invisible**. O la confirma el humano, o queda `[IA-DECIDIÓ]` con su default explícito. El humano puede revertir un `[IA-DECIDIÓ]` en cualquier momento.

## El protocolo (los 6 pasos)

1. **Enumerá lo que asumirías.** Para la fase actual, recorré cada punto donde estás por **elegir algo material** sin haberlo confirmado (un comportamiento, un dato, un contrato, una decisión de diseño, un caso borde, un alcance). Si lo resolverías solo/a sin preguntar → **es una pregunta**.
2. **Agrupá por categoría** (las de tu fase — ver tabla abajo). Agrupar evita el muro de preguntas sueltas y ayuda a decidir por bloques.
3. **Redactá cada pregunta con su default.** Por cada una: la pregunta concreta + **2-4 opciones** (o un **default recomendado** con su razón) + la **consecuencia** de cada opción. **Siempre** incluí la opción **"que decida la IA"** (aplica el default). Una pregunta con un buen default se responde más rápido que una en blanco.
4. **Presentá al humano.** *(Lo hace el hilo principal — los subagentes no hacen Q&A en vivo: producen las preguntas y el comando las presenta.)* Idealmente con la tool de preguntas de opción múltiple. El humano elige por cada una:
   - **Responde / elige una opción** → decisión **humana** (registrá la respuesta).
   - **"Que decida la IA"** → la IA aplica el default y lo marca **`[IA-DECIDIÓ]`** (registrá la decisión y que la tomó la IA).
   - **No está seguro / hay que averiguar** → queda **`[VERIFICAR]`** (bloquea `approved`).
5. **Registrá en el artefacto de la fase** (la `spec.md` / `plan.md` / `tasks.md` correspondiente): qué se preguntó, qué se decidió, y **quién decidió**. Las decisiones `[IA-DECIDIÓ]` van anotadas, no escondidas.
6. **Nunca asumas en silencio.** Si en cualquier punto te encontrás eligiendo algo material que no preguntaste → frená y volvé al paso 1. Ante la mínima duda, preguntá: un falso positivo cuesta una pregunta; una suposición equivocada cuesta retrabajo.

## Categorías por fase (qué preguntar en cada paso)

| Fase (comando) | Categorías a barrer |
|---|---|
| **Spec / Requisitos** (`/spec`) | comportamiento esperado · datos/persistencia · autorización · bordes/errores/estado vacío · **alcance** (qué NO entra) · integración/dependencias |
| **Diseño** (`/plan`, `/contract`) | enfoque/alternativas técnicas · reuso vs. crear · persistencia/modelo de datos · autorización · trade-offs y **complejidad** (toda abstracción/dependencia nueva) · dependencias entre repos/módulos |
| **Tasks** (`/tasks`) | orden y **dependencias** entre tareas · qué tests son obligatorios · granularidad/corte de las tareas |
| **Construcción** (`builder`) | decisiones tácticas que **cambian comportamiento observable** · casos borde que aparecen en el código · cuándo un detalle de implementación amerita volver a la spec |
| **Verify** (`/verify`) | criterios de aceptación ambiguos al verificarlos · qué evidencia cuenta como cumplido · qué escenarios validar en vivo |

> Adaptá las categorías a tu proyecto, pero **no bajes la vara**: en cada fase tiene que haber una pasada de preguntas antes de avanzar.

## Reglas duras

- **En cada fase se hacen preguntas antes de avanzar.** Si no hay ninguna, se declara explícito; no se saltea el paso.
- **Ninguna suposición material es silenciosa.** Toda decisión es humana, `[IA-DECIDIÓ]` (delegada + registrada), o `[VERIFICAR]` (abierta, bloquea).
- **Toda pregunta llega con un default sugerido** y la opción "que decida la IA".
- **El humano siempre puede delegar**, pero la delegación queda **trazable** (`[IA-DECIDIÓ]`), nunca como una elección invisible de la IA.
- Las decisiones de **contrato/comportamiento** que el humano no resuelve son `[VERIFICAR]` (bloquean), no `[IA-DECIDIÓ]`: no se delega en la IA algo que define el contrato sin que el humano lo sepa.

## Side-effects

Read-only sobre el código. El registro de decisiones lo escribe el comando/agente de la fase en su artefacto (`spec.md`/`plan.md`/`tasks.md`), no esta skill. Esta skill define **el protocolo**; cada fase lo ejecuta.
