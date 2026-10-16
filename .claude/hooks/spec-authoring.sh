#!/usr/bin/env sh
#
# Hook de autoria de spec.md / contract.md (specs/NNN-*/) - twin POSIX de
# spec-authoring.ps1, misma logica. La spec describe el sistema, no su
# construccion (specs/CONSTITUTION.md, seccion 6).
#
#   PreToolUse  Edit|Write  deniega lo que la edicion AGREGA de:
#                           - anclas archivo:linea
#                           - changelog fechado ("enmienda del 2026-09-03", "(dev 2026-07-13)")
#                           - conteos de corrida ("34/34 tests", "12 tests en verde")
#                           Compara antes y despues: sacar o dejar lo que ya estaba pasa.
#   PostToolUse Edit|Write  si el archivo quedo por encima del presupuesto de
#                           tamano, avisa (no bloquea), una vez por archivo y sesion.
#
# COMO EDITAR: ajusta BUDGET_SPEC_KB / BUDGET_CONTRACT_KB y EXT a tu stack.
# Requiere `jq`. Sin jq, o ante cualquier error, falla abierto (exit 0).

set +e

BUDGET_SPEC_KB=15
BUDGET_CONTRACT_KB=20
EXT='cs|csproj|py|go|java|kt|rb|rs|php|ts|tsx|js|jsx|vue|swift|c|cpp|h|ps1|sh|json|sql|ya?ml'

raw=$(cat)
[ -z "$raw" ] && exit 0
if ! command -v jq >/dev/null 2>&1; then
    echo "spec-authoring hook error: jq not found; allowing call" >&2
    exit 0
fi

file_path=$(printf '%s' "$raw" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$file_path" ] && exit 0
norm=$(printf '%s' "$file_path" | sed 's#\\#/#g')
match=$(printf '%s' "$norm" | grep -ioE '(^|/)specs/[0-9]{3}[^/]*/(spec|contract)\.md$')
[ -z "$match" ] && exit 0
nombre=$(basename "$norm" | tr 'A-Z' 'a-z')
carpeta=$(basename "$(dirname "$norm")")
evento=$(printf '%s' "$raw" | jq -r '.hook_event_name // empty' 2>/dev/null)

if [ "$evento" = "PostToolUse" ]; then
    [ -f "$file_path" ] || exit 0
    bytes=$(wc -c < "$file_path" | tr -d ' ')
    tope=$BUDGET_SPEC_KB
    [ "$nombre" = "contract.md" ] && tope=$BUDGET_CONTRACT_KB
    [ "$bytes" -le $((tope * 1024)) ] && exit 0
    session=$(printf '%s' "$raw" | jq -r '.session_id // "nosession"' 2>/dev/null)
    marca="${TMPDIR:-/tmp}/sdd-spec-authoring-${session}.txt"
    if [ -f "$marca" ] && grep -qxF "$norm" "$marca"; then exit 0; fi
    echo "$norm" >> "$marca"
    kb=$(awk -v b="$bytes" 'BEGIN { printf "%.1f", b/1024 }')
    msg="$carpeta/$nombre pesa $kb KB (presupuesto $tope KB). Una spec describe el sistema, no su construccion (specs/CONSTITUTION.md, seccion 6): si esta edicion agrego proceso, sacalo; si es una spec done vieja, compactarla (skill spec-sanitize) es trabajo aparte."
    jq -n --arg msg "$msg" '{ hookSpecificOutput: { hookEventName: "PostToolUse", additionalContext: $msg } }'
    exit 0
fi

# PreToolUse: antes / despues a archivos temporales
tmp=$(mktemp -d 2>/dev/null || echo "${TMPDIR:-/tmp}/spec-authoring.$$")
mkdir -p "$tmp"
trap 'rm -rf "$tmp"' EXIT
kind=$(printf '%s' "$raw" | jq -r 'if .tool_input.content != null then "write" elif .tool_input.edits != null then "multi" else "edit" end' 2>/dev/null)
case "$kind" in
    write)
        printf '%s' "$raw" | jq -r '.tool_input.content' > "$tmp/after"
        if [ -f "$file_path" ]; then cp "$file_path" "$tmp/before"; else : > "$tmp/before"; fi ;;
    multi)
        printf '%s' "$raw" | jq -r '[.tool_input.edits[].old_string] | join("\n")' > "$tmp/before"
        printf '%s' "$raw" | jq -r '[.tool_input.edits[].new_string] | join("\n")' > "$tmp/after" ;;
    *)
        printf '%s' "$raw" | jq -r '.tool_input.old_string // ""' > "$tmp/before"
        printf '%s' "$raw" | jq -r '.tool_input.new_string // ""' > "$tmp/after" ;;
esac

# nombre|regex (ERE, case-insensitive)
cat > "$tmp/patterns" <<EOF
ancla archivo:linea|[A-Za-z0-9_.-]+\.($EXT)[[:space:]]*:[[:space:]]*[0-9]+
changelog fechado|(enmienda|actualizad[oa]|corregid[oa]|reconciliaci..?n|decidid[oa]|resuelt[oa]|cerrad[oa]).{0,60}20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]
changelog fechado|(^|[^A-Za-z])dev[[:space:]]*,?[[:space:]]*20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]
conteo de corrida|[0-9]+[[:space:]]*/[[:space:]]*[0-9]+[[:space:]]+(tests?|AC|criterios|casos|verdes?)([^A-Za-z]|$)
conteo de corrida|[0-9]+[[:space:]]+tests?[[:space:]]+(en[[:space:]]+)?verdes?([^A-Za-z]|$)
EOF

total_a=0; total_d=0; detalle=""
while IFS='|' read -r nombre_p rx; do
    [ -z "$rx" ] && continue
    na=$(grep -oiE "$rx" "$tmp/before" 2>/dev/null | wc -l | tr -d ' ')
    nd=$(grep -oiE "$rx" "$tmp/after" 2>/dev/null | wc -l | tr -d ' ')
    total_a=$((total_a + na)); total_d=$((total_d + nd))
    if [ "$nd" -gt "$na" ]; then
        ej=$(grep -oiE "$rx" "$tmp/after" 2>/dev/null | head -n1)
        detalle="${detalle}${detalle:+, }$nombre_p ('$ej')"
    fi
done < "$tmp/patterns"

[ "$total_d" -le "$total_a" ] && exit 0

reason="La spec describe el sistema, no su construccion (specs/CONSTITUTION.md, seccion 6). Esta edicion agrega: $detalle. Una decision se escribe como regla o criterio, sin fecha; la evidencia es el test que cita el AC (ancla Spec/AC), no archivo:linea ni conteos."
jq -n --arg reason "$reason" '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason } }'
exit 2
