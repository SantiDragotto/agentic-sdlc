---
name: tasks
description: Descompone el plan en una checklist atómica de tareas (incl. tests obligatorios)
argument-hint: "[NNN-slug]"
---

Estás en la fase **Tasks** del flujo SDD (ver `specs/README.md`). Para: $ARGUMENTS

1. Leé la `spec.md`, `plan.md` y (si existe) `contract.md` de la feature, y `specs/TEMPLATE/tasks.md`. Esta fase la maneja el hilo principal — no delega en un agente.
2. Generá `specs/NNN-slug/tasks.md`: tareas atómicas en orden de ejecución. Cada tarea mapea a uno o más criterios de aceptación (columna **"Cubre AC"**) y declara sus prerequisitos en la columna **"Dep."** (número[s] de tarea de la que depende, o `[P]` si puede correr en paralelo con sus hermanas); todo AC queda cubierto por al menos una tarea.
3. Incluí explícitamente las **tareas de test obligatorias** según las convenciones del proyecto (ver AGENTS.md → testing). Como mínimo, una tarea de test por cada criterio de aceptación de borde/error y de autorización.
   [EJEMPLO — reemplazar por las reglas reales de tu proyecto]
   - Un test por cada escenario de autorización (acceso permitido / denegado / no autenticado).
   - Un test que verifique cada invariante de persistencia declarado en la spec.
   - El tag/categoría de test que use tu suite para separar unit de integración.
4. **Antes de cerrar `tasks.md`, corré el protocolo `clarify`** (skill `clarify`) sobre orden y **dependencias** entre tareas, qué tests son obligatorios, y granularidad/corte de las tareas. Toda duda se presenta como pregunta con su default sugerido + la opción "que decida la IA": lo que **delego en la IA** se aplica con su default y queda anotado en `tasks.md` como **`[IA-DECIDIÓ]`** (no bloquea); lo que queda sin resolver va como **`[VERIFICAR]`** (bloquea). Si no hay ambigüedades en esta fase, declaralo explícito — no asumas en silencio.
