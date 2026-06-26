#!/usr/bin/env pwsh
# ------------------------------------------------------------------------------
# validate-sdd  —  Validador DETERMINISTICO de artefactos SDD.
#
# Recorre specs/NNN-*/ y verifica los gates de PROCESO que no dependen de
# criterio humano: convierte en "duros" los gates que de otro modo serian solo
# conductuales. Los chequeos SEMANTICOS (cobertura criterio<->tarea, calidad del
# criterio) los cubren /analyze y el ingeniero; aca solo lo mecanico y objetivo.
#
# Salida: lista de ERROR / WARN. Exit 1 si hay errores, 0 si no. WARN no falla.
# Excluye specs/TEMPLATE/ (placeholders). Incluye el ejemplo 000-* (debe pasar).
#
# Uso:    powershell -NoProfile -File validate-sdd.ps1 [-SpecsDir specs]
#   o     pwsh validate-sdd.ps1
# Twin POSIX equivalente (misma logica): validate-sdd.sh
# ------------------------------------------------------------------------------
[CmdletBinding()]
param([string]$SpecsDir = "specs")

$errs  = New-Object System.Collections.Generic.List[string]
$warns = New-Object System.Collections.Generic.List[string]

function Get-Frontmatter([string]$path) {
  $fm = @{}
  $lines = Get-Content -LiteralPath $path -ErrorAction SilentlyContinue
  if (-not $lines -or $lines.Count -lt 1 -or $lines[0].Trim() -ne '---') { return $fm }
  for ($i = 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i].Trim() -eq '---') { break }
    if ($lines[$i] -match '^\s*([A-Za-z0-9_-]+)\s*:\s*(.*)$') {
      $fm[$matches[1]] = ($matches[2] -replace '#.*$', '').Trim()
    }
  }
  return $fm
}

# Cuenta [VERIFICAR] "vivos": preguntas abiertas reales. Excluye los tachados
# (~~...~~ = resueltos) y las referencias al token entre backticks (`[VERIFICAR]`,
# que aparecen en prosa y en los checklists de "Criterios de salida").
function Get-OpenVerificarCount([string]$path) {
  $m = @(Select-String -LiteralPath $path -Pattern '\[VERIFICAR\]' | Where-Object {
      ($_.Line -notmatch '~~') -and ($_.Line -notmatch '`\[VERIFICAR\]`')
    })
  return $m.Count
}

# Cuenta marcadores [IA-DECIDE]/[IA-DECIDIO] vivos (decisiones delegadas a la IA).
# Match ASCII por prefijo \[IA-DECID para no depender del acento en el patron.
function Get-IADecideCount([string]$path) {
  $m = @(Select-String -LiteralPath $path -Pattern '\[IA-DECID' | Where-Object {
      ($_.Line -notmatch '~~') -and ($_.Line -notmatch '`\[IA-DECID')
    })
  return $m.Count
}

function Test-Empty([string]$v) {
  return ([string]::IsNullOrWhiteSpace($v) -or ($v -match '^<.*>$'))
}

if (-not (Test-Path -LiteralPath $SpecsDir)) { Write-Host "ERROR: no existe '$SpecsDir/'"; exit 2 }

$dirs  = @(Get-ChildItem -LiteralPath $SpecsDir -Directory | Where-Object { $_.Name -match '^\d{3}-' })
$index = Join-Path $SpecsDir 'INDEX.md'

foreach ($d in $dirs) {
  $name = $d.Name
  $spec = Join-Path $d.FullName 'spec.md'
  if (-not (Test-Path -LiteralPath $spec)) { $errs.Add("$name : falta spec.md"); continue }

  $fm = Get-Frontmatter $spec
  $status = $fm['status']

  foreach ($k in @('name', 'status')) {
    if (-not $fm.ContainsKey($k) -or [string]::IsNullOrWhiteSpace($fm[$k])) {
      $errs.Add("$name/spec.md : falta la key de frontmatter '$k'")
    }
  }

  $advanced = @('approved', 'in-progress', 'done') -contains $status

  if ($advanced) {
    $ov = Get-OpenVerificarCount $spec
    if ($ov -gt 0) { $errs.Add("$name/spec.md : status '$status' con $ov [VERIFICAR] sin resolver") }
    if (Test-Empty $fm['approved-by']) {
      $errs.Add("$name/spec.md : status '$status' requiere 'approved-by:' poblado (trazabilidad de la decision humana)")
    }
  }

  if ($status -eq 'done') {
    $unchecked = @(Select-String -LiteralPath $spec -Pattern '^\s*-\s*\[ \]')
    if ($unchecked.Count -gt 0) {
      $errs.Add("$name/spec.md : status 'done' con $($unchecked.Count) checkbox(es) sin tildar (- [ ])")
    }
  }

  $iad = Get-IADecideCount $spec
  if ($iad -gt 0) { $warns.Add("$name/spec.md : $iad decision(es) marcada(s) IA-DECIDE (la IA decidio por default) - revisalas con el humano") }

  $contract = $fm['contract']
  if ($contract -and ($contract -notmatch '^n/?a') -and ($contract -match '^\.{1,2}/')) {
    if (-not (Test-Path -LiteralPath (Join-Path $d.FullName $contract))) {
      $errs.Add("$name/spec.md : contract '$contract' apunta a un archivo inexistente")
    }
  }

  if (Test-Path -LiteralPath $index) {
    $nnn = ($name -split '-')[0]
    if (-not (Select-String -LiteralPath $index -Pattern $nnn -SimpleMatch -Quiet)) {
      $warns.Add("$name : sin fila en INDEX.md (no aparece '$nnn')")
    }
  }

  $cmd = Join-Path $d.FullName 'contract.md'
  if (Test-Path -LiteralPath $cmd) {
    $cfm = Get-Frontmatter $cmd
    if ($cfm['status'] -eq 'shipped') {
      $cov = Get-OpenVerificarCount $cmd
      if ($cov -gt 0) { $errs.Add("$name/contract.md : status 'shipped' con $cov [VERIFICAR] sin resolver") }
      if (Test-Empty $cfm['approved-by']) {
        $errs.Add("$name/contract.md : status 'shipped' requiere 'approved-by:' poblado")
      }
    }
  }
}

Write-Host ("SDD validate - {0} feature(s) en {1}/" -f $dirs.Count, $SpecsDir)
foreach ($w in $warns) { Write-Host ("  WARN  {0}" -f $w) }
foreach ($e in $errs)  { Write-Host ("  ERROR {0}" -f $e) }
if ($errs.Count -gt 0) {
  Write-Host ("FALLO: {0} error(es), {1} warning(s)." -f $errs.Count, $warns.Count)
  exit 1
}
Write-Host ("OK: 0 errores, {0} warning(s)." -f $warns.Count)
exit 0
