# `000-EXAMPLE-abierta/` — ejemplo a mitad de construcción (read-only)

La feature de referencia "marcar ítems como favoritos y ver la lista" **mientras se construye**: spec `in-progress`, contrato `approved`, plan aprobado y `tasks.md` con la mitad de las tareas hechas. Es lo que ves en tu repo entre `/tasks` y `/verify`.

- Los **4 artefactos** están llenos: leelos al lado de las plantillas vacías de `../TEMPLATE/`.
- Fijate en lo que va a **sobrevivir al cierre**: cada respuesta a una pregunta está escrita como regla (`spec.md` §2, `contract.md` §5) o como criterio, no como pregunta tachada; cada tarea de test declara su ancla `Spec`/`AC`.
- La **misma feature cerrada** está en `../000-EXAMPLE-cerrada/`: comparalas para ver qué borra `/verify` y cuánto pesa cada una.
- Corré `/validate-specs` y vas a verlo **pasar** el gate determinístico.
- **No lo edites.** Borrá las dos carpetas de ejemplo juntas cuando ya entiendas el flujo.
