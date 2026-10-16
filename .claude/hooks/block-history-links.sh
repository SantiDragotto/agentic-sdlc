#!/usr/bin/env sh
#
# PreToolUse hook (Edit|Write) - twin POSIX de block-history-links.ps1, misma
# logica. Deniega escribir un link a historia en un archivo vivo
# (specs/CONSTITUTION.md, seccion 6: la historia vive solo en git y no se
# linkea): ningun archivo vivo apunta a un archivo borrado, a un commit ni a un tag.
#
# En codigo (archivo fuera de specs/ y .claude/ con extension de codigo),
# ademas: citas al proceso de una spec (plan.md, tasks.md, tarea T3), que se
# borran al cerrarla. Se cita la regla o el criterio (spec NNN AC3).
#
# Solo deniega lo que la edicion AGREGA (compara antes y despues). Quedan
# afuera CLAUDE.md, AGENTS.md, .claude/hooks/, .claude/skills/spec-sanitize/ y
# los temporales.
#
# COMO EDITAR: suma a PATTERNS las carpetas de archivo de tu repo y ajusta
# EXT_CODIGO a tu stack.
# Requiere `jq`. Sin jq, o ante cualquier error, falla abierto (exit 0).

set +e

EXT_CODIGO='cs|py|go|java|kt|rb|rs|php|ts|tsx|js|jsx|vue|swift|c|cpp|h|sql'

raw=$(cat)
[ -z "$raw" ] && exit 0
if ! command -v jq >/dev/null 2>&1; then
    echo "block-history-links hook error: jq not found; allowing call" >&2
    exit 0
fi

file_path=$(printf '%s' "$raw" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$file_path" ] && exit 0
norm=$(printf '%s' "$file_path" | sed 's#\\#/#g')

printf '%s' "$norm" | grep -qiE '(^|/)(CLAUDE|AGENTS)\.md$' && exit 0
printf '%s' "$norm" | grep -qiE '(^|/)\.claude/(hooks|skills/spec-sanitize)/' && exit 0
tmpdir_norm=$(printf '%s' "${TMPDIR:-/tmp}" | sed 's#\\#/#g; s#/*$##')
case "$norm" in /tmp/* | "$tmpdir_norm"/*) exit 0 ;; esac

tmp=$(mktemp -d 2>/dev/null || echo "${TMPDIR:-/tmp}/block-history-links.$$")
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

# flags|regex (ERE). i = case-insensitive, - = case-sensitive.
cat > "$tmp/patterns" <<'EOF'
i|(^|[^A-Za-z0-9_])_archive/
i|(^|[^A-Za-z0-9_])docs/archive([^A-Za-z0-9_]|$)
i|git[[:space:]]+show[[:space:]]+[^<[:space:]`'"][^[:space:]`'"]*:
i|git[[:space:]]+show[[:space:]]+[0-9a-f]{7,40}([^0-9a-f]|$)
i|commit[[:space:]]+`?[0-9a-f]{7,40}([^0-9a-f]|$)
EOF

if printf '%s' "$norm" | grep -qiE "\.($EXT_CODIGO)$" && ! printf '%s' "$norm" | grep -qiE '(^|/)(specs|\.claude)/'; then
    cat >> "$tmp/patterns" <<'EOF'
i|(^|[^A-Za-z0-9_])plan\.md([^A-Za-z0-9_]|$)
i|(^|[^A-Za-z0-9_])tasks\.md([^A-Za-z0-9_]|$)
i|(^|[^A-Za-z0-9_])plan[[:space:]]*§[[:space:]]*[0-9]
i|(^|[^A-Za-z0-9_])tarea[[:space:]]+T?[0-9]{1,3}([^0-9]|$)
-|\(T[0-9]{1,3}\)
i|specs?[[:space:]]+[0-9]{3}[[:space:]]*(·|/|,|\(|-)[[:space:]]*T[0-9]{1,3}([^0-9]|$)
EOF
fi

count() {  # $1 = archivo; cuenta todas las ocurrencias de todos los patrones
    n=0
    while IFS='|' read -r flag rx; do
        [ -z "$rx" ] && continue
        if [ "$flag" = "i" ]; then c=$(grep -oiE "$rx" "$1" 2>/dev/null | wc -l | tr -d ' ')
        else c=$(grep -oE "$rx" "$1" 2>/dev/null | wc -l | tr -d ' '); fi
        n=$((n + c))
    done < "$tmp/patterns"
    # SHA suelto entre backticks: hex de 7 a 40 con al menos una letra y un digito
    c=$(grep -oE '`[0-9a-f]{7,40}`' "$1" 2>/dev/null | grep '[a-f]' | grep -c '[0-9]')
    echo $((n + c))
}

first_link() {
    while IFS='|' read -r flag rx; do
        [ -z "$rx" ] && continue
        if [ "$flag" = "i" ]; then m=$(grep -oiE "$rx" "$1" 2>/dev/null | head -n1)
        else m=$(grep -oE "$rx" "$1" 2>/dev/null | head -n1); fi
        [ -n "$m" ] && { echo "$m"; return; }
    done < "$tmp/patterns"
    grep -oE '`[0-9a-f]{7,40}`' "$1" 2>/dev/null | grep '[a-f]' | grep '[0-9]' | head -n1
}

na=$(count "$tmp/before")
nd=$(count "$tmp/after")
[ "$nd" -le "$na" ] && exit 0

link=$(first_link "$tmp/after")
reason="La historia no se linkea (specs/CONSTITUTION.md, seccion 6): '$link' en $file_path. Si el dato sigue importando, reescribilo como regla o comportamiento en el archivo vivo; si no, sacalo. En codigo, cita la regla o el criterio (spec NNN AC3), nunca plan.md/tasks.md ni sus rotulos: se borran al cerrar la spec."
jq -n --arg reason "$reason" '{ hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason } }'
exit 2
