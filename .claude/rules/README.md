# `.claude/rules/` — placeholder

Esta carpeta está **vacía intencionalmente**.

## Modelo actual: A (rules centralizadas)

Hoy todas las reglas pasivas viven en:

- **`AGENTS.md`** (raíz del repo) — contratos no negociables, comandos, topology
- **`CLAUDE.md`** (raíz del repo) — comportamiento agéntico, design patterns, testing standards

Ambos archivos se cargan automáticamente al inicio de cada sesión de Claude Code. Funcionan bien mientras el conjunto de rules sea acotado.

## Por qué Modelo A por ahora

- Pocas rules totales (≤30 entre ambos archivos)
- `CLAUDE.md` se mantiene <200 líneas — bajo costo de tokens
- Cero overhead de mantenimiento de un index
- Otras herramientas de IA leen `AGENTS.md` directamente sin atomización

## Cuándo migrar a Modelo B (atomizado)

Considerar la migración cuando se cumpla **al menos uno** de estos triggers:

- `CLAUDE.md` supera ~300 líneas
- Hooks o skills empiezan a referenciar rules específicas (necesitan link estable)
- Distintos contributors necesitan ownership claro de subsets de rules
- Aparece la necesidad de versionar/desactivar rules selectivamente

## Cómo sería el refactor a Modelo B

1. Crear archivos por topic en esta carpeta:
   - `.claude/rules/topic-a.md`
   - `.claude/rules/topic-b.md`
   - `.claude/rules/testing.md`
   - `.claude/rules/secrets.md`
   - etc.
2. `CLAUDE.md` queda como índice corto con links explícitos:
   ```
   ## Rules
   - [Topic A](.claude/rules/topic-a.md)
   - [Topic B](.claude/rules/topic-b.md)
   - ...
   ```
3. Cada archivo de rules se carga via `@.claude/rules/<file>.md` en `CLAUDE.md` o se referencia desde hooks/skills.

## Mientras tanto

**No crear archivos hermanos en esta carpeta.** El único contenido válido aquí es este README. Si tenés una rule nueva que agregar, va a `CLAUDE.md` o `AGENTS.md` según corresponda (ver criterio en `AGENTS.md > Repo Contracts` vs `CLAUDE.md > Behavioral Rules`).
