<#
.SYNOPSIS
Hook de autoria de spec.md / contract.md (specs/NNN-*/): la spec describe el sistema, no su construccion.
Twin PowerShell de spec-authoring.sh.

.DESCRIPTION
Defiende specs/CONSTITUTION.md, seccion 6. Corre en dos eventos:

  PreToolUse  Edit|Write  deniega lo que la edicion AGREGA de estas formas de proceso:
                          - anclas archivo:linea (envejecen; la evidencia es el test que cita el AC)
                          - changelog fechado ("enmienda del 2026-09-03", "(dev 2026-07-13)")
                          - conteos de corrida ("34/34 tests", "12 tests en verde")
                          Compara antes y despues: sacar o dejar lo que ya estaba pasa.
  PostToolUse Edit|Write  si el archivo quedo por encima del presupuesto de tamano, avisa (no bloquea),
                          una vez por archivo y sesion.

COMO EDITAR: ajusta $presupuestoKb y la lista de extensiones de la ancla archivo:linea a tu stack.

Errores del hook: exit 0 (fail-open: nunca traba el trabajo por un bug propio).
#>

$ErrorActionPreference = 'Stop'

$presupuestoKb = @{ 'spec.md' = 15; 'contract.md' = 20 }

$extensiones = 'cs|csproj|py|go|java|kt|rb|rs|php|ts|tsx|js|jsx|vue|swift|c|cpp|h|ps1|sh|json|sql|ya?ml'
$patrones = @(
    @{ Nombre = 'ancla archivo:linea'; Rx = '\b[\w.-]+\.(' + $extensiones + ')\s*:\s*\d+' },
    @{ Nombre = 'changelog fechado';   Rx = '(?i)\b(enmienda|actualizad[oa]|corregid[oa]|reconciliaci.n|decidid[oa]|resuelt[oa]|cerrad[oa])\b.{0,60}?\b20\d\d-\d\d-\d\d\b' },
    @{ Nombre = 'changelog fechado';   Rx = '(?i)\bdev\s*,?\s*20\d\d-\d\d-\d\d\b' },
    @{ Nombre = 'conteo de corrida';   Rx = '(?i)\b\d+\s*/\s*\d+\s+(tests?|AC|criterios|casos|verdes?)\b' },
    @{ Nombre = 'conteo de corrida';   Rx = '(?i)\b\d+\s+tests?\s+(en\s+)?verdes?\b' }
)

function Get-Hallazgos([string] $text) {
    $out = @{}
    if ([string]::IsNullOrEmpty($text)) { return $out }
    foreach ($p in $patrones) {
        foreach ($m in [regex]::Matches($text, $p.Rx)) {
            if (-not $out.ContainsKey($p.Nombre)) { $out[$p.Nombre] = @() }
            $out[$p.Nombre] += $m.Value
        }
    }
    return $out
}

function Get-Total($h) { $n = 0; foreach ($k in $h.Keys) { $n += $h[$k].Count }; return $n }

try {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

    $payload  = $raw | ConvertFrom-Json
    $evento   = [string]$payload.hook_event_name
    $in       = $payload.tool_input
    $filePath = [string]$in.file_path
    if ([string]::IsNullOrWhiteSpace($filePath)) { exit 0 }

    $norm = $filePath -replace '\\', '/'
    $m = [regex]::Match($norm, '(?i)(^|/)specs/(\d{3}[^/]*)/(spec|contract)\.md$')
    if (-not $m.Success) { exit 0 }
    $nombre = $m.Groups[3].Value.ToLower() + '.md'

    if ($evento -eq 'PostToolUse') {
        if (-not (Test-Path -LiteralPath $filePath)) { exit 0 }
        $kb = [math]::Round((Get-Item -LiteralPath $filePath).Length / 1KB, 1)
        $tope = $presupuestoKb[$nombre]
        if ($kb -le $tope) { exit 0 }

        $marca = Join-Path ([IO.Path]::GetTempPath()) ('sdd-spec-authoring-' + [string]$payload.session_id + '.txt')
        $vistos = @()
        if (Test-Path -LiteralPath $marca) { $vistos = @(Get-Content -LiteralPath $marca) }
        if ($vistos -contains $norm) { exit 0 }
        Add-Content -LiteralPath $marca -Value $norm

        $msg = "$($m.Groups[2].Value)/$nombre pesa $kb KB (presupuesto $tope KB). Una spec describe el sistema, no su construccion (specs/CONSTITUTION.md, seccion 6): si esta edicion agrego proceso, sacalo; si es una spec done vieja, compactarla (skill spec-sanitize) es trabajo aparte."
        @{ hookSpecificOutput = @{ hookEventName = 'PostToolUse'; additionalContext = $msg } } |
            ConvertTo-Json -Depth 5 -Compress | Write-Output
        exit 0
    }

    # PreToolUse
    $antes = ''; $despues = ''
    if ($null -ne $in.content) {
        $despues = [string]$in.content
        if (Test-Path -LiteralPath $filePath) { $antes = [IO.File]::ReadAllText($filePath) }
    }
    elseif ($null -ne $in.edits) {
        foreach ($e in $in.edits) { $antes += [string]$e.old_string + "`n"; $despues += [string]$e.new_string + "`n" }
    }
    else {
        $antes = [string]$in.old_string
        $despues = [string]$in.new_string
    }

    $hA = Get-Hallazgos $antes
    $hD = Get-Hallazgos $despues
    if ((Get-Total $hD) -le (Get-Total $hA)) { exit 0 }

    $detalle = @()
    foreach ($k in $hD.Keys) {
        $nA = 0; if ($hA.ContainsKey($k)) { $nA = $hA[$k].Count }
        if ($hD[$k].Count -gt $nA) { $detalle += "$k ('$($hD[$k][0])')" }
    }

    $reason = @(
        "La spec describe el sistema, no su construccion (specs/CONSTITUTION.md, seccion 6).",
        "Esta edicion agrega: $($detalle -join ', ').",
        "Una decision se escribe como regla o criterio, sin fecha; la evidencia es el test que cita el AC (ancla Spec/AC), no archivo:linea ni conteos."
    ) -join ' '

    @{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = $reason } } |
        ConvertTo-Json -Depth 5 -Compress | Write-Output
    exit 2
}
catch {
    [Console]::Error.WriteLine("spec-authoring hook error: $($_.Exception.Message)")
    exit 0
}
