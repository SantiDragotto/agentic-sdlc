# `000-EXAMPLE-cerrada/` — ejemplo cerrado (read-only)

La **misma feature** que `../000-EXAMPLE-abierta/`, después de pasar `/verify` y la compactación `spec-sanitize --cierre` (`../CONSTITUTION.md §6`). Es la forma en que queda **toda** spec `done` del corpus, y la que van a cargar las sesiones futuras.

| | Abierta (en construcción) | Cerrada (`done` / `shipped`) |
|---|---|---|
| Archivos | `spec.md` · `contract.md` · `plan.md` · `tasks.md` | `spec.md` · `contract.md` |
| `spec.md` | §1–§9 + criterios de salida | §1, §2, §4 (criterios tildados, una línea c/u), §6 — sin renumerar |
| `contract.md` | §1–§8 + notas del template + criterios de salida | §1–§6 + §8 en una línea |
| Peso | ~25 KB | ~5,4 KB (−78%) |

Qué hizo el cierre, paso por paso:

- **Borró el andamio**: `plan.md`, `tasks.md`, y de la spec el análisis del problema, el contrato producido, las preguntas, las notas, los supuestos y los criterios de salida.
- **No perdió ninguna decisión**: la cascada al borrar un ítem y el `204` (no `404`) al desmarcar ya estaban escritos como regla (`spec.md` §2, `contract.md` §5) antes de cerrar; el plan se pudo borrar sin pérdida.
- **Condensó los criterios** a una línea (ID + qué afirma): cada uno lo cita un test con el ancla `Spec=000`/`AC=ACn`, que es la versión ejecutable del detalle.
- **Podó lo que dice el código**: la tabla de entidad quedó como un puntero al módulo más las reglas propias (unicidad, cascada).
- **La evidencia** del contrato quedó en una línea: los tests de la spec en verde, sin `archivo:línea` ni commits.

Lo que se borró sigue en git, pero ningún archivo vivo lo linkea. **No lo edites.** Borrá las dos carpetas de ejemplo juntas cuando ya entiendas el flujo.
