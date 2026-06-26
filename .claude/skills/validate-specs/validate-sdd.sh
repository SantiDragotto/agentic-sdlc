#!/usr/bin/env sh
# ------------------------------------------------------------------------------
# validate-sdd  —  Validador DETERMINISTICO de artefactos SDD (twin POSIX de
# validate-sdd.ps1, misma logica).
#
# Recorre specs/NNN-*/ y verifica los gates de PROCESO que no dependen de
# criterio humano: convierte en "duros" gates que de otro modo serian solo
# conductuales. Lo SEMANTICO (cobertura criterio<->tarea, calidad del criterio)
# lo cubren /analyze y el ingeniero; aca solo lo mecanico y objetivo.
#
# Exit 1 si hay errores, 0 si no. WARN no falla. Excluye specs/TEMPLATE/.
# Uso:  sh validate-sdd.sh [specs_dir]
# ------------------------------------------------------------------------------
set -u
SPECS_DIR="${1:-specs}"
errs=0
warns=0

# imprime el bloque de frontmatter (entre los dos primeros '---'); tolera un BOM UTF-8 en la linea 1
frontmatter() {
  awk 'NR==1{sub(/^\xef\xbb\xbf/,"")} NR==1 && $0!="---"{exit} /^---[[:space:]]*$/{c++; if(c==2) exit; next} c==1{print}' "$1"
}
# valor de una key del frontmatter, sin comentario inline ni espacios
fm_get() {
  printf '%s\n' "$1" | grep -E "^$2:" | head -n1 | sed -E "s/^$2:[[:space:]]*//; s/#.*$//; s/[[:space:]]+$//"
}
# cuenta [VERIFICAR] "vivos": preguntas abiertas reales. Excluye los tachados
# (~~...~~) y las referencias al token entre backticks (`[VERIFICAR]`).
open_verificar() {
  grep -E '\[VERIFICAR\]' "$1" 2>/dev/null | grep -v '~~' | grep -v '`\[VERIFICAR\]`' | wc -l | tr -d ' '
}
# cuenta marcadores [IA-DECIDE]/[IA-DECIDIO] vivos (decisiones delegadas a la IA); match ASCII por prefijo
ia_decide() {
  grep -E '\[IA-DECID' "$1" 2>/dev/null | grep -v '~~' | grep -v '`\[IA-DECID' | wc -l | tr -d ' '
}
# vacio o placeholder <...>
is_empty() {
  case "$1" in "") return 0 ;; '<'*'>') return 0 ;; *) return 1 ;; esac
}

err()  { echo "  ERROR $1"; errs=$((errs + 1)); }
warn() { echo "  WARN  $1"; warns=$((warns + 1)); }

[ -d "$SPECS_DIR" ] || { echo "ERROR: no existe '$SPECS_DIR/'"; exit 2; }

count=0
for d in "$SPECS_DIR"/[0-9][0-9][0-9]-*/; do
  [ -d "$d" ] || continue
  count=$((count + 1))
  name=$(basename "$d")
  spec="${d}spec.md"
  if [ ! -f "$spec" ]; then err "$name : falta spec.md"; continue; fi

  fm=$(frontmatter "$spec")
  status=$(fm_get "$fm" "status")
  name_k=$(fm_get "$fm" "name")
  [ -n "$name_k" ] || err "$name/spec.md : falta la key de frontmatter 'name'"
  [ -n "$status" ] || err "$name/spec.md : falta la key de frontmatter 'status'"

  advanced=0
  case "$status" in approved | in-progress | done) advanced=1 ;; esac

  if [ "$advanced" = "1" ]; then
    ov=$(open_verificar "$spec")
    [ "$ov" -gt 0 ] && err "$name/spec.md : status '$status' con $ov [VERIFICAR] sin resolver"
    ab=$(fm_get "$fm" "approved-by")
    if is_empty "$ab"; then err "$name/spec.md : status '$status' requiere 'approved-by:' poblado (trazabilidad de la decision humana)"; fi
  fi

  if [ "$status" = "done" ]; then
    unchk=$(grep -E '^[[:space:]]*-[[:space:]]*\[ \]' "$spec" 2>/dev/null | wc -l | tr -d ' ')
    [ "$unchk" -gt 0 ] && err "$name/spec.md : status 'done' con $unchk checkbox(es) sin tildar (- [ ])"
  fi

  iad=$(ia_decide "$spec")
  [ "$iad" -gt 0 ] && warn "$name/spec.md : $iad decision(es) marcada(s) IA-DECIDE (la IA decidio por default) - revisalas con el humano"

  contract=$(fm_get "$fm" "contract")
  case "$contract" in
    ./* | ../*)
      [ -f "${d}${contract}" ] || err "$name/spec.md : contract '$contract' apunta a un archivo inexistente"
      ;;
  esac

  if [ -f "$SPECS_DIR/INDEX.md" ]; then
    nnn=$(printf '%s' "$name" | cut -d- -f1)
    grep -q "$nnn" "$SPECS_DIR/INDEX.md" || warn "$name : sin fila en INDEX.md (no aparece '$nnn')"
  fi

  cmd="${d}contract.md"
  if [ -f "$cmd" ]; then
    cfm=$(frontmatter "$cmd")
    cstatus=$(fm_get "$cfm" "status")
    if [ "$cstatus" = "shipped" ]; then
      cov=$(open_verificar "$cmd")
      [ "$cov" -gt 0 ] && err "$name/contract.md : status 'shipped' con $cov [VERIFICAR] sin resolver"
      cab=$(fm_get "$cfm" "approved-by")
      if is_empty "$cab"; then err "$name/contract.md : status 'shipped' requiere 'approved-by:' poblado"; fi
    fi
  fi
done

echo "SDD validate - $count feature(s) en $SPECS_DIR/"
if [ "$errs" -gt 0 ]; then
  echo "FALLO: $errs error(es), $warns warning(s)."
  exit 1
fi
echo "OK: 0 errores, $warns warning(s)."
exit 0
