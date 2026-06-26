#!/usr/bin/env sh
#
# PreToolUse hook (POSIX twin of block-forbidden-command.ps1).
#
# Blocks any Bash command that matches a forbidden pattern. Defends a repo
# contract documented in AGENTS.md > Commands. Reads the PreToolUse JSON
# payload from stdin, inspects tool_input.command, and denies the call
# (exit 2 + JSON output) when it matches the forbidden pattern. Any other
# command is allowed (exit 0).
#
# HOW TO EDIT:
#   1. Replace the PATTERN regex below with the command you want to block.
#      It is matched case-insensitively (grep -iE) against the raw command.
#      Examples:
#        - a migration command: '\bmigrate\b'
#        - a deploy command:    '\bdeploy[[:space:]]+--prod\b'
#   2. Adjust the reason text so it points at YOUR contract and tells the
#      model what to do instead (ask the developer to run it).
#
# Requires `jq`. If jq is missing, the hook fails open (allows the call).

# Fail-open guard: any unexpected error allows the call.
set +e

raw=$(cat)
[ -z "$raw" ] && exit 0

if ! command -v jq >/dev/null 2>&1; then
    echo "block-forbidden-command hook error: jq not found; allowing call" >&2
    exit 0
fi

command=$(printf '%s' "$raw" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$command" ] && exit 0

# <patrón-de-comando-prohibido> — EDITAR: regex del comando que querés bloquear.
PATTERN='<patron-de-comando-prohibido>'

if ! printf '%s' "$command" | grep -iEq "$PATTERN"; then
    exit 0
fi

reason="Repo contract: agents must not run this command. Command blocked: ${command} Ask the developer to run it. See AGENTS.md > Commands."

jq -n --arg reason "$reason" '{
    hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $reason
    }
}'

exit 2
