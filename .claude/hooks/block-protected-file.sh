#!/usr/bin/env sh
#
# PreToolUse hook (POSIX twin of block-protected-file.ps1).
#
# Blocks Edit/Write on a protected file. Defends a repo contract documented in
# AGENTS.md > Repo Contracts > Secrets and Local Config. Reads the PreToolUse
# JSON payload from stdin, inspects tool_input.file_path, and denies the call
# (exit 2 + JSON output) when the path targets the protected file. Any other
# path is allowed (exit 0).
#
# HOW TO EDIT:
#   1. Replace the PATTERN regex below with the file you want to protect.
#      It is matched case-insensitively (grep -iE) against tool_input.file_path.
#      The `$` anchors the end of the path. Escape literal dots as \.
#      Examples:
#        - a secrets file: 'secrets\.local\.json$'
#        - an env file:    '\.env(\.[A-Za-z]+)?$'
#   2. Adjust the reason text so it points at YOUR contract.
#
# Requires `jq`. If jq is missing, the hook fails open (allows the call).

# Fail-open guard: any unexpected error allows the call.
set +e

raw=$(cat)
[ -z "$raw" ] && exit 0

if ! command -v jq >/dev/null 2>&1; then
    echo "block-protected-file hook error: jq not found; allowing call" >&2
    exit 0
fi

file_path=$(printf '%s' "$raw" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$file_path" ] && exit 0

# <patrón-de-archivo-protegido> — EDITAR: regex del archivo que querés proteger.
PATTERN='<patron-de-archivo-protegido>$'

if ! printf '%s' "$file_path" | grep -iEq "$PATTERN"; then
    exit 0
fi

reason="Repo contract: this file must not be modified by agents. Path blocked: ${file_path} If a value is needed for a task, ask the user to provide it inline. See AGENTS.md > Repo Contracts > Secrets and Local Config."

jq -n --arg reason "$reason" '{
    hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $reason
    }
}'

exit 2
