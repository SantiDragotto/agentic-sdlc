<#
.SYNOPSIS
PreToolUse hook (Edit|Write): deniega escribir un link a historia en un archivo vivo.
Twin PowerShell de block-history-links.sh.

.DESCRIPTION
Defiende specs/CONSTITUTION.md, seccion 6 (la historia vive solo en git y no se linkea): ningun archivo
vivo apunta a un archivo borrado, a un commit ni a un tag. Si algo del pasado sigue importando, se
reescribe como regla en el archivo vivo.

En codigo (cualquier archivo fuera de specs/ y .claude/ con extension de codigo), ademas: citas al
proceso de una spec. plan.md y tasks.md se borran al cerrarla, asi que un comentario que los cita queda
colgado. Se cita la regla o el criterio (spec NNN AC3), no el rotulo de proceso.

Solo deniega lo que la edicion AGREGA: compara las ocurrencias antes y despues, asi que sacar un link
viejo, o editar cerca de uno, pasa. Quedan afuera los archivos que documentan la regla (CLAUDE.md,
AGENTS.md, .claude/hooks/, .claude/skills/spec-sanitize/) y los temporales.

COMO EDITAR: suma a $patrones las carpetas de archivo de tu repo (ej. '(?i)\bdocs/old/') y ajusta
$extCodigo a tu stack.

Errores del hook: exit 0 (fail-open).
#>

$ErrorActionPreference = 'Stop'

$patrones = @(
    '(?i)\b_archive/',
    '(?i)\bdocs/archive\b',
    '(?i)\bgit\s+show\s+(?!<)[^\s`''"]+:',
    '(?i)\bgit\s+show\s+[0-9a-f]{7,40}\b',
    '(?i)\bcommit\s+`?[0-9a-f]{7,40}\b',
    # SHA suelto entre backticks: hex de 7 a 40 con al menos una letra y un digito (no fechas ni numeros)
    '`(?=[0-9a-f]*[a-f])(?=[0-9a-f]*\d)[0-9a-f]{7,40}`'
)

$patronesCodigo = @(
    '(?i)\bplan\.md\b',
    '(?i)\btasks\.md\b',
    '(?i)\bplan\s*§\s*\d',
    '(?i)\btarea\s+T?\d{1,3}\b',
    '\(T\d{1,3}\)',
    '(?i)\bspecs?\s+\d{3}\s*[·/,(-]\s*T\d{1,3}\b'
)

$extCodigo = 'cs|py|go|java|kt|rb|rs|php|ts|tsx|js|jsx|vue|swift|c|cpp|h|sql'

function Get-Patrones([string] $path) {
    if ($path -match ('(?i)\.(' + $extCodigo + ')$') -and $path -notmatch '(?i)(^|/)(specs|\.claude)/') {
        return $patrones + $patronesCodigo
    }
    return $patrones
}

function Count-Links([string] $text, [string[]] $pats) {
    if ([string]::IsNullOrEmpty($text)) { return 0 }
    $n = 0
    foreach ($p in $pats) { $n += [regex]::Matches($text, $p).Count }
    return $n
}

function First-Link([string] $text, [string[]] $pats) {
    foreach ($p in $pats) {
        $m = [regex]::Match($text, $p)
        if ($m.Success) { return $m.Value }
    }
    return ''
}

try {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

    $payload = $raw | ConvertFrom-Json
    $in = $payload.tool_input
    $filePath = [string]$in.file_path
    if ([string]::IsNullOrWhiteSpace($filePath)) { exit 0 }

    $norm = $filePath -replace '\\', '/'
    if ($norm -match '(?i)(^|/)(CLAUDE|AGENTS)\.md$' -or $norm -match '(?i)(^|/)\.claude/(hooks|skills/spec-sanitize)/') { exit 0 }
    # Los temporales (scratchpad, /tmp) no son archivos vivos.
    $tmp = ([IO.Path]::GetTempPath() -replace '\\', '/').TrimEnd('/')
    if ($norm.StartsWith($tmp, [StringComparison]::OrdinalIgnoreCase) -or $norm -match '^/tmp/') { exit 0 }

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

    $pats = Get-Patrones $norm
    if ((Count-Links $despues $pats) -le (Count-Links $antes $pats)) { exit 0 }

    $reason = @(
        "La historia no se linkea (specs/CONSTITUTION.md, seccion 6): '$(First-Link $despues $pats)' en $filePath.",
        "Si el dato sigue importando, reescribilo como regla o comportamiento en el archivo vivo; si no, sacalo.",
        "En codigo, cita la regla o el criterio (spec NNN AC3), nunca plan.md/tasks.md ni sus rotulos: se borran al cerrar la spec."
    ) -join ' '

    @{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = $reason } } |
        ConvertTo-Json -Depth 5 -Compress | Write-Output
    exit 2
}
catch {
    [Console]::Error.WriteLine("block-history-links hook error: $($_.Exception.Message)")
    exit 0
}
