<#
.SYNOPSIS
PreToolUse hook: blocks Edit/Write on a protected file.

.DESCRIPTION
Template hook. Defends a repo contract documented in
AGENTS.md > Repo Contracts > Secrets and Local Config.
Reads the PreToolUse JSON payload from stdin, inspects tool_input.file_path, and
denies the call (exit 2 + JSON output) when the path targets the protected file.

Use this to keep agents away from a secrets/local-config file (e.g.
{{SECRETS_FILE}}) or any file only a human should touch. Any other path is
allowed (exit 0).

HOW TO EDIT:
  1. Replace the $pattern regex below with the file you want to protect.
     It is a case-insensitive (?i) .NET regex matched against tool_input.file_path.
     The `$` anchors the end of the path so it matches the filename suffix.
     Escape literal dots as \. — Examples:
       - a secrets file:      '(?i)secrets\.local\.json$'
       - an env file:         '(?i)\.env(\.[A-Za-z]+)?$'
  2. Adjust the $reason text so it points at YOUR contract.
#>

$ErrorActionPreference = 'Stop'

try {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

    $payload = $raw | ConvertFrom-Json
    $filePath = [string]$payload.tool_input.file_path
    if ([string]::IsNullOrWhiteSpace($filePath)) { exit 0 }

    # <patrón-de-archivo-protegido> — EDITAR: regex del archivo que querés proteger.
    $pattern = '(?i)<patron-de-archivo-protegido>$'
    if ($filePath -notmatch $pattern) { exit 0 }

    $reason = @(
        "Repo contract: this file must not be modified by agents.",
        "Path blocked: $filePath",
        "If a value is needed for a task, ask the user to provide it inline.",
        "See AGENTS.md > Repo Contracts > Secrets and Local Config."
    ) -join " "

    $response = @{
        hookSpecificOutput = @{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = $reason
        }
    }

    $response | ConvertTo-Json -Depth 5 -Compress | Write-Output
    exit 2
}
catch {
    # Hook errors must not block the user (fail-open). Log to stderr and allow the call.
    [Console]::Error.WriteLine("block-protected-file hook error: $($_.Exception.Message)")
    exit 0
}
