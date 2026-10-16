#!/usr/bin/env sh
# ------------------------------------------------------------------------------
# compact-spec  -  Borra el material de PROCESO de las specs cerradas (status:
# done). Twin POSIX de compact-spec.ps1, misma logica. Dry-run por default.
# La historia queda en git, y no se linkea (specs/CONSTITUTION.md, seccion 6).
#
# Una spec done conserva solo spec.md y contract.md. plan.md, tasks.md y
# cualquier otro .md de la carpeta se borran (git rm si estan versionados; del
# disco si nunca se commitearon). Reescribir spec.md/contract.md a la forma
# minima NO es trabajo de este script: lo hace la skill spec-sanitize (Paso 3).
#
# Guard de churn: no toca una spec con commits de TRABAJO en los ultimos N dias.
#   Es mantenimiento (no cuenta) un commit que solo toca specs/, o que toca 10 o
#   mas carpetas de spec a la vez. --closing lo saltea (cierre desde /verify).
# Guard de referencias: no borra un archivo citado por path desde fuera de
#   specs/ (codigo, .claude/, docs); frena esa spec. --force lo saltea.
# Links colgantes: lista las lineas de specs/ que van a quedar apuntando a lo
#   que se borra, y los comentarios fuera de specs/ que citan el proceso.
# Nunca toca carpetas de ejemplo (*-EXAMPLE-*).
#
# Uso: sh compact-spec.sh [--spec NNN] [--quiet-days N] [--closing] [--force]
#                         [--execute] [--specs-dir specs]
# Exit 0 = ok. 1 = con --spec, la spec no se pudo procesar (no existe, no esta
# done, es un ejemplo o la freno un guard). 2 = error de uso o de entorno.
# ------------------------------------------------------------------------------
set -u

SPEC=""; QUIET_DAYS=14; CLOSING=0; FORCE=0; EXECUTE=0; SPECS_DIR="specs"
while [ $# -gt 0 ]; do
  case "$1" in
    --spec) SPEC="${2:-}"; shift 2 ;;
    --quiet-days) QUIET_DAYS="${2:-14}"; shift 2 ;;
    --closing) CLOSING=1; shift ;;
    --force) FORCE=1; shift ;;
    --execute) EXECUTE=1; shift ;;
    --specs-dir) SPECS_DIR="${2:-specs}"; shift 2 ;;
    *) echo "argumento desconocido: $1"; exit 2 ;;
  esac
done

if [ "$CLOSING" = "1" ] && [ -z "$SPEC" ]; then echo "--closing cierra UNA spec: pasale --spec NNN."; exit 2; fi

repo=$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null) || { echo "No es un repo git: compact-spec necesita git."; exit 2; }
cd "$repo" || exit 2
SPECS_DIR=$(printf '%s' "$SPECS_DIR" | sed 's#\\#/#g; s#/*$##')
[ -d "$SPECS_DIR" ] || { echo "No encuentro $SPECS_DIR/ en $repo"; exit 2; }

wanted=""
[ -n "$SPEC" ] && wanted=$(printf '%03d' "$(expr "$SPEC" + 0)")

tmp=$(mktemp -d 2>/dev/null || echo "${TMPDIR:-/tmp}/compact-spec.$$")
mkdir -p "$tmp"
trap 'rm -rf "$tmp"' EXIT
: > "$tmp/plan"; : > "$tmp/skipped"; : > "$tmp/colgantes"; : > "$tmp/files"

found=0

# commits de TRABAJO (no mantenimiento) sobre la carpeta en la ventana
work_commits() {
  n=0
  for h in $(git log --since="$QUIET_DAYS days ago" --format=%H -- "$1"); do
    files=$(git show --name-only --format= "$h" | grep -v '^$')
    outside=$(printf '%s\n' "$files" | grep -v "^$SPECS_DIR/" | grep -c . )
    folders=$(printf '%s\n' "$files" | sed -n "s#^$SPECS_DIR/\([0-9][0-9][0-9][^/]*\)/.*#\1#p" | sort -u | grep -c . )
    if [ "$outside" -gt 0 ] && [ "$folders" -lt 10 ]; then n=$((n + 1)); fi
  done
  echo "$n"
}

for d in "$SPECS_DIR"/[0-9][0-9][0-9]-*/; do
  [ -d "$d" ] || continue
  slug=$(basename "$d")
  id=$(printf '%s' "$slug" | cut -c1-3)
  [ -n "$wanted" ] && [ "$id" != "$wanted" ] && continue
  found=1
  rel="$SPECS_DIR/$slug"

  if printf '%s' "$slug" | grep -qi -- '-EXAMPLE-'; then
    [ -n "$wanted" ] && echo "$slug|carpeta de ejemplo: no se compacta" >> "$tmp/skipped"
    continue
  fi
  if [ ! -f "$rel/spec.md" ]; then
    [ -n "$wanted" ] && echo "$slug|sin spec.md" >> "$tmp/skipped"
    continue
  fi
  status=$(grep -m1 -E '^status:' "$rel/spec.md" | sed -E 's/^status:[[:space:]]*//; s/[[:space:]#].*$//')
  if [ "$status" != "done" ]; then
    [ -n "$wanted" ] && echo "$slug|status '$status', no done" >> "$tmp/skipped"
    continue
  fi

  files=""
  for f in "$rel"/*.md; do
    [ -f "$f" ] || continue
    case "$(basename "$f")" in spec.md | contract.md) continue ;; esac
    files="$files $f"
  done
  [ -z "$files" ] && continue

  if [ "$CLOSING" = "0" ]; then
    churn=$(work_commits "$rel")
    if [ "$churn" -gt 0 ]; then echo "$slug|$churn commit(s) de trabajo en $QUIET_DAYS dias" >> "$tmp/skipped"; continue; fi
  fi

  : > "$tmp/duras"; : > "$tmp/links"
  for f in $files; do
    fname=$(basename "$f")
    fesc=$(printf '%s' "$fname" | sed 's/\./\\./g')
    git grep -n -I -E "${id}(-[a-z0-9-]+)?/${fesc}" 2>/dev/null | while IFS= read -r l; do
      p=$(printf '%s' "$l" | cut -d: -f1)
      ln=$(printf '%s' "$l" | cut -d: -f2)
      case " $files " in *" $p "*) continue ;; esac   # se va junto con lo que cita
      case "$p" in
        "$SPECS_DIR"/*) echo "$p:$ln -> $fname" >> "$tmp/links" ;;
        *) echo "$fname <- $p:$ln" >> "$tmp/duras" ;;
      esac
    done
    # dentro de la propia spec se cita sin carpeta: `plan.md`, `./tasks.md`
    for own in spec.md contract.md; do
      [ -f "$rel/$own" ] || continue
      grep -n -i -E "(^|[[:space:]\`(/])${fesc}([^A-Za-z0-9_]|$)" "$rel/$own" 2>/dev/null | cut -d: -f1 | while IFS= read -r ln; do
        echo "$rel/$own:$ln -> $fname" >> "$tmp/links"
      done
    done
  done
  num=$(expr "$id" + 0)
  git grep -n -I -E "[Ss]pecs? 0*${num}([^0-9]|$).{0,60}(plan\.md|tasks\.md|plan .?[0-9]|tareas? [0-9]|[( ]T[0-9]{1,3}[) ,.:])" -- . ":(exclude)$SPECS_DIR" 2>/dev/null \
    | cut -d: -f1,2 | while IFS= read -r l; do echo "$l -> comentario que cita el proceso de la $id" >> "$tmp/links"; done

  if [ -s "$tmp/duras" ] && [ "$FORCE" = "0" ]; then
    echo "$slug|citado desde fuera de specs/: $(sort -u "$tmp/duras" | tr '\n' ';' | sed 's/;$//; s/;/; /g')" >> "$tmp/skipped"
    continue
  fi
  cat "$tmp/links" "$tmp/duras" >> "$tmp/colgantes"

  bytes=$(cat $files | wc -c | tr -d ' ')
  names=$(for f in $files; do basename "$f"; done | tr '\n' ',' | sed 's/,$//; s/,/, /g')
  echo "$bytes|$slug|$names" >> "$tmp/plan"
  for f in $files; do echo "$f" >> "$tmp/files"; done
done

# ---------------------------------------------------------------- reporte
count=$(grep -c . "$tmp/plan")
tot=$(awk -F'|' '{s+=$1} END {print s+0}' "$tmp/plan")
echo ""
[ -n "$wanted" ] && [ "$found" = "0" ] && echo "  No existe una carpeta $SPECS_DIR/$wanted-*."
[ "$EXECUTE" = "0" ] && echo "  DRY-RUN - nada se borro. Agrega --execute para aplicar."
awk -v c="$count" -v b="$tot" 'BEGIN { printf "  Specs done con proceso a borrar: %d  (%.1f KB, ~%d tokens)\n", c, b/1024, b/4 }'
sort -t'|' -k1,1nr "$tmp/plan" | head -n 15 | awk -F'|' '{ printf "    %-50s %7.1f KB   %s\n", $2, $1/1024, $3 }'
[ "$count" -gt 15 ] && echo "    ... y $((count - 15)) mas"
skipped=$(grep -c . "$tmp/skipped")
if [ "$skipped" -gt 0 ]; then
  echo "  Salteadas: $skipped"
  awk -F'|' '{ printf "    %-50s %s\n", $1, $2 }' "$tmp/skipped"
fi
sort -u "$tmp/colgantes" > "$tmp/colgantes.u"
ncol=$(grep -c . "$tmp/colgantes.u")
if [ "$ncol" -gt 0 ]; then
  echo "  Links que van a quedar colgando: $ncol. Sacalos antes del commit (la historia no se linkea):"
  sed 's/^/    /' "$tmp/colgantes.u"
fi
echo ""

spec_failed=0
if [ -n "$wanted" ] && { [ "$found" = "0" ] || [ "$skipped" -gt 0 ]; }; then spec_failed=1; fi
if [ "$EXECUTE" = "0" ]; then exit "$spec_failed"; fi

# ---------------------------------------------------------------- aplicar
n=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  if [ -z "$(git ls-files -- "$f")" ]; then
    rm -f -- "$f"   # nunca se commiteo: solo del disco
  elif [ "$CLOSING" = "1" ]; then
    git rm -q -f -- "$f" || { echo "git rm fallo: $f"; exit 2; }   # plan/tasks con tareas tildadas sin commitear
  else
    git rm -q -- "$f" || { echo "git rm fallo: $f"; exit 2; }
  fi
  n=$((n + 1))
done < "$tmp/files"
awk -v n="$n" -v b="$tot" 'BEGIN { printf "  %d archivo(s) borrado(s) (%.1f KB).\n", n, b/1024 }'
[ "$ncol" -gt 0 ] && echo "  Falta sacar los links listados arriba."
exit "$spec_failed"
