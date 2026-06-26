# `.claude/hooks/`

Scripts shell que el harness de Claude Code (no el modelo) ejecuta en eventos. Determinísticos, sin IA. Ideales para defensa-en-profundidad de repo contracts y automatización event-driven.

## Eventos disponibles

| Evento | Cuándo dispara |
|---|---|
| `PreToolUse` | Antes de ejecutar un tool call. Puede **bloquear** el call. |
| `PostToolUse` | Después de un tool call exitoso. Útil para format/lint automáticos. |
| `UserPromptSubmit` | Al enviar un prompt. Puede **inyectar contexto** (git status, branch). |
| `Stop` / `SubagentStop` | Al finalizar respuesta del modelo o subagente. |
| `SessionStart` | Al iniciar una sesión de Claude Code. |
| `PreCompact` | Antes de compactar contexto. |
| `Notification` | Recepción de notificación. |

## Registro: `settings.json` vs `settings.local.json`

- **`.claude/settings.json`** (committed): hooks que protegen **repo contracts** o automatizan tareas que TODO contributor necesita.
- **`.claude/settings.local.json`** (gitignored): hooks de preferencia personal del developer.

Formato:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "<comando del runner de hooks> \"${CLAUDE_PROJECT_DIR}/.claude/hooks/<script>\"" }
        ]
      }
    ]
  }
}
```

`matcher` admite alternancia regex (`Edit|Write` matchea ambas tools en una sola entrada).

### Cross-platform: elegir el runner del hook

Cada hook de este template viene en dos versiones gemelas: un runner PowerShell (`*.ps1`) y un runner POSIX (`*.sh`). Reemplazá `<comando del runner de hooks>` por el launcher que corresponda a tu entorno:

- **Windows PowerShell 5.1** (`powershell.exe`):
  ```
  powershell -NoProfile -ExecutionPolicy Bypass -File
  ```
  > **Nota**: si usás PowerShell 7 (`pwsh`) en vez de Windows PowerShell 5.1, reemplazá `powershell` por `pwsh` en cada invocación.
- **PowerShell 7 cross-platform** (`pwsh`):
  ```
  pwsh -NoProfile -ExecutionPolicy Bypass -File
  ```
- **POSIX (Linux/macOS, sh/bash)** — apuntá al gemelo `.sh`:
  ```
  sh
  ```
  es decir, en `settings.json` el comando queda `sh "${CLAUDE_PROJECT_DIR}/.claude/hooks/<script>.sh"`.

El template registra los `.ps1` por defecto en `settings.json`. **En un proyecto POSIX, cambiá el launcher `powershell -File .../*.ps1` por `sh .../*.sh`.** El contrato de stdin/stdout (ver abajo) es idéntico en ambos runners, así que no hace falta tocar la lógica.

## Stdin del script

El harness pasa JSON por stdin con el contexto del evento. Campos relevantes:

- **PreToolUse Bash**: `tool_input.command`
- **PreToolUse Edit/Write**: `tool_input.file_path`

Patrón PowerShell:

```powershell
$payload = [Console]::In.ReadToEnd() | ConvertFrom-Json
$command = $payload.tool_input.command
```

Patrón POSIX (con `jq`):

```sh
payload=$(cat)
command=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')
```

## Cómo bloquear un tool call

- Salir con **exit code 2**
- Imprimir en stdout JSON con `permissionDecision: "deny"` y `permissionDecisionReason`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "<mensaje que Claude verá>"
  }
}
```

`exit 0` = permitir. Cualquier no-cero distinto de 2 = error del hook (no bloqueo limpio).

## Convenciones

- Cada hook se shipea en dos runners gemelos (`*.ps1` para PowerShell, `*.sh` para POSIX). Registrá en `settings.json` el que corresponda a tu OS (ver "Cross-platform" arriba).
- **NO reemplazan** las rules de `CLAUDE.md`/`AGENTS.md` — las refuerzan.
- Mensajes de bloqueo deben **explicar cómo proceder** (qué pedirle al developer, dónde está la regla).
- **Fail-open**: si el hook tira una excepción, debe permitir el call (exit 0) y loguear a stderr, nunca dejar al usuario trabado por un bug del hook.
- Validar manualmente antes de mergear: hooks corren con permisos del usuario.

## Activos en este template

Los **2 hooks** de ejemplo, cableados en `.claude/settings.json`. Ambos son **plantillas**: editá el patrón interno para que apunte a tu comando/archivo real. Cada uno se shipea en dos runners gemelos (`.ps1` + `.sh`).

| Hook | Evento | Qué bloquea | Archivos |
|---|---|---|---|
| `block-forbidden-command` | `PreToolUse` (Bash) | Un comando Bash prohibido (ej. `{{MIGRATION_COMMAND}}`) | `block-forbidden-command.{ps1,sh}` |
| `block-protected-file` | `PreToolUse` (Edit\|Write) | Edit/Write a un archivo protegido (ej. `{{SECRETS_FILE}}`) | `block-protected-file.{ps1,sh}` |

- `block-forbidden-command.{ps1,sh}` — bloquea un comando Bash prohibido (ej. `{{MIGRATION_COMMAND}}` u otra operación que solo un humano debe correr). Defensa de repo contract `AGENTS.md > Commands`. Editá el patrón regex dentro del script.
- `block-protected-file.{ps1,sh}` — bloquea Edit/Write sobre un archivo protegido (ej. `{{SECRETS_FILE}}`). Defensa de repo contract `AGENTS.md > Repo Contracts > Secrets and Local Config`. Editá el patrón de path dentro del script.

## Roadmap (ideas para extender)

- `format-source` (`PostToolUse` Edit/Write sobre `{{SOURCE_ROOT}}`) — corre el formateador/linter del stack automáticamente.
- `branch-context` (`UserPromptSubmit`) — inyecta `git branch` y commits recientes.
