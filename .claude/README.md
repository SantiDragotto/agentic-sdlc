# `.claude/` — maquinaria de IA del kit

Acá vive todo lo que Claude Code usa para operar bajo el flujo SDD: comandos por fase, agentes especializados, skills, hooks de defensa en profundidad y la config committeada. El harness carga estas carpetas automáticamente al iniciar la sesión.

| Subcarpeta / archivo | Cuenta | Qué es | Detalle |
|---|---|---|---|
| `commands/` | 6 | Un comando fino por fase del flujo (`/spec` `/plan` `/tasks` `/analyze` `/verify` `/contract`); cada uno delega en un agente (salvo `/tasks`, hilo principal). `/contract` es OPCIONAL. | [`commands/README.md`](./commands/README.md) |
| `agents/` | 7 | Subagentes con rol profesional (analista de requisitos, arquitecto, QA, ingeniero sénior, V&V, e2e) que ejecutan cada etapa con contexto aislado. | [`agents/README.md`](./agents/README.md) |
| `skills/` | 4 | Workflows estructurados con auto-trigger: `bug-finder`, `validate-specs` (gate determinístico + CI), `setup` (onboarding), `clarify` (preguntas por fase). | [`skills/README.md`](./skills/README.md) |
| `hooks/` | 2 | Guardas determinísticas que el harness corre en eventos (`PreToolUse`): `block-forbidden-command` y `block-protected-file`, cada uno `.ps1` + `.sh`. | [`hooks/README.md`](./hooks/README.md) |
| `rules/` | 0 | Placeholder intencionalmente vacío: hoy las reglas pasivas viven centralizadas en `CLAUDE.md` + `AGENTS.md` (Modelo A). | [`rules/README.md`](./rules/README.md) |
| `settings.json` | — | Config committeada del repo: registra los hooks en `PreToolUse` (elegí runner PowerShell `.ps1` o POSIX `.sh`). | — |

Cada subcarpeta tiene su propio README con el detalle (cuándo agregar cada cosa, frontmatter, convenciones).
