<#
.SYNOPSIS
    Borra el material de PROCESO de las specs cerradas (status: done). Twin de compact-spec.sh.
    Dry-run por default. La historia queda en git, y no se linkea (specs/CONSTITUTION.md, seccion 6).

.DESCRIPTION
    Una spec done conserva solo spec.md y contract.md. plan.md, tasks.md y cualquier otro .md de la
    carpeta cuentan como se construyo algo que ya esta construido: se borran (git rm si estan
    versionados; del disco si nunca se commitearon). Reescribir spec.md/contract.md a la forma minima
    NO es trabajo de este script: lo hace la skill spec-sanitize (Paso 3).

    Guard de churn: no toca una spec con commits de TRABAJO en los ultimos -QuietDays dias. Es
    mantenimiento del corpus (no cuenta) un commit que solo toca specs/, o que toca 10 o mas carpetas de
    spec a la vez (una feature toca 1 a 3; renumerar o compactar tocan decenas). Cuida el trabajo en
    vuelo de otros al compactar el stock; al cerrar desde /verify el trabajo reciente es el propio, y
    -Closing lo saltea.
    Guard de referencias: no borra un archivo citado por path desde fuera de specs/ (codigo, .claude/,
    docs); frena esa spec y lo lista. -Force lo saltea.
    Links colgantes: lista las lineas de specs/ que van a quedar apuntando a lo que se borra, y los
    comentarios fuera de specs/ que citan el proceso de la spec (plan.md, tasks.md, tarea T3). Se sacan
    antes del commit.
    Nunca toca carpetas de ejemplo (*-EXAMPLE-*).

.PARAMETER Spec
    NNN de la spec. Sin esto, evalua todas las 'done'.
.PARAMETER QuietDays
    Ventana del guard de churn. Default 14.
.PARAMETER Closing
    Cierre de la spec desde /verify: saltea el guard de churn y borra aunque haya cambios sin
    commitear. Requiere -Spec.
.PARAMETER Force
    Saltea el guard de referencias.
.PARAMETER Execute
    Aplica el borrado. Sin esto es dry-run.
.PARAMETER SpecsDir
    Carpeta de specs relativa a la raiz del repo. Default 'specs'.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .claude/skills/spec-sanitize/compact-spec.ps1
.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .claude/skills/spec-sanitize/compact-spec.ps1 -Spec 012 -Closing -Execute

    Exit 0 = ok. Exit 1 = con -Spec, la spec no se pudo procesar (no existe, no esta done, es un
    ejemplo o la freno un guard). Exit 2 = error de uso o de entorno.
#>
[CmdletBinding()]
param(
    [string] $Spec,
    [int]    $QuietDays = 14,
    [switch] $Closing,
    [switch] $Force,
    [switch] $Execute,
    [string] $SpecsDir = 'specs'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Closing -and -not $Spec) { Write-Host '-Closing cierra UNA spec: pasale -Spec NNN.'; exit 2 }

$repo = (& git -C $PSScriptRoot rev-parse --show-toplevel 2>$null)
if (-not $repo) { Write-Host 'No es un repo git: compact-spec necesita git.'; exit 2 }
$repo = ($repo | Select-Object -First 1).Trim()
$specsPath = Join-Path $repo $SpecsDir
if (-not (Test-Path $specsPath)) { Write-Host "No encuentro $SpecsDir/ en $repo"; exit 2 }

$specsRel = ($SpecsDir -replace '\\', '/').TrimEnd('/')
$durable  = @('spec.md', 'contract.md')
$wanted   = $null
if ($Spec) { $wanted = '{0:D3}' -f [int]$Spec }

# Proceso de una spec citado desde fuera de specs/ (comentarios de codigo): plan.md, tasks.md, tarea N, T3.
function Get-ProcessCitations([string] $id) {
    $n  = [int]$id
    $rx = "[Ss]pecs? 0*$n([^0-9]|$).{0,60}(plan\.md|tasks\.md|plan .?[0-9]|tareas? [0-9]|[( ]T[0-9]{1,3}[) ,.:])"
    $out = @()
    foreach ($l in @(& git -C $repo grep -n -I -E $rx -- . ":(exclude)$specsRel" 2>$null)) {
        if (-not $l) { continue }
        $p = $l -split ':', 3
        if ($p.Count -ge 2) { $out += "$($p[0]):$($p[1]) -> comentario que cita el proceso de la $id" }
    }
    return $out
}

# Commits de TRABAJO (no mantenimiento) sobre la carpeta en la ventana.
function Get-WorkCommits([string] $relDir) {
    $out = @()
    foreach ($h in @(& git -C $repo log "--since=$QuietDays days ago" --format=%H -- $relDir)) {
        if (-not $h) { continue }
        $files   = @(& git -C $repo show --name-only --format= $h | Where-Object { $_ })
        $outside = @($files | Where-Object { -not $_.StartsWith("$specsRel/") }).Count
        $folders = @($files | ForEach-Object {
                if ($_ -match ('^' + [regex]::Escape($specsRel) + '/(\d{3}[^/]*)/')) { $Matches[1] }
            } | Select-Object -Unique).Count
        if ($outside -gt 0 -and $folders -lt 10) { $out += $h }
    }
    return $out
}

$plan = @(); $skipped = @(); $colgantes = @()
$found = $false

foreach ($dir in @(Get-ChildItem -Path $specsPath -Directory | Sort-Object Name)) {
    $m = [regex]::Match($dir.Name, '^(\d{3})-')
    if (-not $m.Success) { continue }
    $id = $m.Groups[1].Value
    if ($wanted -and $id -ne $wanted) { continue }
    $found = $true
    $relDir = "$specsRel/$($dir.Name)"

    if ($dir.Name -match '(?i)-EXAMPLE-') {
        if ($wanted) { $skipped += [pscustomobject]@{ Slug = $dir.Name; Razon = 'carpeta de ejemplo: no se compacta' } }
        continue
    }

    $sf = Join-Path $dir.FullName 'spec.md'
    if (-not (Test-Path $sf)) {
        if ($wanted) { $skipped += [pscustomobject]@{ Slug = $dir.Name; Razon = 'sin spec.md' } }
        continue
    }
    $sm = [regex]::Match([IO.File]::ReadAllText($sf), '(?m)^status:\s*([^\s#]+)')
    $status = ''
    if ($sm.Success) { $status = $sm.Groups[1].Value }
    if ($status -ne 'done') {
        if ($wanted) { $skipped += [pscustomobject]@{ Slug = $dir.Name; Razon = "status '$status', no done" } }
        continue
    }

    $files = @(Get-ChildItem -Path $dir.FullName -File -Filter '*.md' | Where-Object { $durable -notcontains $_.Name })
    if ($files.Count -eq 0) { continue }

    if (-not $Closing) {
        $churn = @(Get-WorkCommits $relDir)
        if ($churn.Count -gt 0) {
            $skipped += [pscustomobject]@{ Slug = $dir.Name; Razon = "$($churn.Count) commit(s) de trabajo en $QuietDays dias" }
            continue
        }
    }

    $borrados = @($files | ForEach-Object { "$relDir/$($_.Name)" })
    $duras = @(); $links = @()
    foreach ($f in $files) {
        $rx = $id + '(-[a-z0-9-]+)?/' + [regex]::Escape($f.Name)
        foreach ($l in @(& git -C $repo grep -n -I -E $rx 2>$null)) {
            if (-not $l) { continue }
            $p = $l -split ':', 3
            if ($p.Count -lt 3) { continue }
            if ($borrados -contains $p[0]) { continue }   # se va junto con lo que cita
            if ($p[0].StartsWith("$specsRel/")) { $links += "$($p[0]):$($p[1]) -> $($f.Name)" }
            else { $duras += "$($f.Name) <- $($p[0]):$($p[1])" }
        }
        # dentro de la propia spec se cita sin carpeta: `plan.md`, `./tasks.md`
        foreach ($own in $durable) {
            $op = Join-Path $dir.FullName $own
            if (-not (Test-Path $op)) { continue }
            $i = 0
            foreach ($line in [IO.File]::ReadAllLines($op)) {
                $i++
                if ($line -match ('(?i)(^|[\s`(/])' + [regex]::Escape($f.Name) + '\b')) {
                    $links += "$relDir/${own}:$i -> $($f.Name)"
                }
            }
        }
    }
    $links += @(Get-ProcessCitations $id)

    if ($duras.Count -gt 0 -and -not $Force) {
        $skipped += [pscustomobject]@{ Slug = $dir.Name; Razon = 'citado desde fuera de specs/: ' + ((@($duras) | Select-Object -Unique) -join '; ') }
        continue
    }
    $colgantes += @(($links + $duras) | Select-Object -Unique)

    $plan += [pscustomobject]@{
        Slug  = $dir.Name
        Files = $files
        Kb    = [math]::Round((($files | Measure-Object Length -Sum).Sum) / 1KB, 1)
    }
}

# ---------------------------------------------------------------- reporte
$totKb = 0
if ($plan.Count -gt 0) { $totKb = ($plan | Measure-Object Kb -Sum).Sum }

Write-Host ''
if ($wanted -and -not $found) { Write-Host "  No existe una carpeta $SpecsDir/$wanted-*." -ForegroundColor Yellow }
if (-not $Execute) { Write-Host '  DRY-RUN - nada se borro. Agrega -Execute para aplicar.' -ForegroundColor Yellow }
Write-Host ('  Specs done con proceso a borrar: {0}  ({1:N1} KB, ~{2:N0} tokens)' -f $plan.Count, $totKb, ($totKb * 1024 / 4)) -ForegroundColor Cyan
$plan | Sort-Object Kb -Descending | Select-Object -First 15 | ForEach-Object {
    Write-Host ('    {0,-50} {1,7:N1} KB   {2}' -f $_.Slug, $_.Kb, (($_.Files | ForEach-Object { $_.Name }) -join ', '))
}
if ($plan.Count -gt 15) { Write-Host ('    ... y {0} mas' -f ($plan.Count - 15)) }
if ($skipped.Count -gt 0) {
    Write-Host ('  Salteadas: {0}' -f $skipped.Count) -ForegroundColor DarkGray
    $skipped | ForEach-Object { Write-Host ('    {0,-50} {1}' -f $_.Slug, $_.Razon) -ForegroundColor DarkGray }
}
if ($colgantes.Count -gt 0) {
    Write-Host ('  Links que van a quedar colgando: {0}. Sacalos antes del commit (la historia no se linkea):' -f $colgantes.Count) -ForegroundColor Yellow
    $colgantes | ForEach-Object { Write-Host ('    {0}' -f $_) -ForegroundColor Yellow }
}
Write-Host ''

$specFailed = [bool]($wanted -and ((-not $found) -or $skipped.Count -gt 0))
if (-not $Execute) { if ($specFailed) { exit 1 } else { exit 0 } }

# ---------------------------------------------------------------- aplicar
$n = 0
foreach ($p in $plan) {
    foreach ($f in $p.Files) {
        $tracked = @(& git -C $repo ls-files -- $f.FullName | Where-Object { $_ })
        if ($tracked.Count -eq 0) {
            # Nunca se commiteo: no hay nada que sacar del indice, solo del disco.
            Remove-Item -LiteralPath $f.FullName
        }
        else {
            # Al cerrar, plan/tasks suelen tener cambios sin commitear (las tareas tildadas): se van igual.
            if ($Closing) { & git -C $repo rm -q -f -- $f.FullName } else { & git -C $repo rm -q -- $f.FullName }
            if ($LASTEXITCODE -ne 0) { Write-Host "git rm fallo: $($f.FullName)"; exit 2 }
        }
        $n++
    }
}
Write-Host ('  {0} archivo(s) borrado(s) ({1:N1} KB).' -f $n, $totKb) -ForegroundColor Green
if ($colgantes.Count -gt 0) { Write-Host '  Falta sacar los links listados arriba.' -ForegroundColor Yellow }
if ($specFailed) { exit 1 }
exit 0
