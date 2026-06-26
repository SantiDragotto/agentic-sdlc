<#
.SYNOPSIS
PreToolUse hook: blocks any Bash command that matches a forbidden pattern.

.DESCRIPTION
Template hook. Defends a repo contract documented in AGENTS.md > Commands.
Reads the PreToolUse JSON payload from stdin, inspects tool_input.command, and
denies the call (exit 2 + JSON output) when it matches the forbidden pattern.

Use this to block commands that only a human should run (e.g. a schema/data
migration command, a deploy, a destructive reset). Any other command is
allowed (exit 0).

HOW TO EDIT:
  1. Replace the $pattern regex below with the command you want to block.
     It is a case-insensitive (?i) .NET regex matched against the raw command
     string. \s+ tolerates extra whitespace; \b anchors a word boundary.
     Examples:
       - a migration command: '(?i)\bmigrate\b'
       - a deploy command:    '(?i)\bdeploy\s+--prod\b'
  2. Adjust the $reason text so it points at YOUR contract and tells the model
     what to do instead (ask the developer to run it).
#>

$ErrorActionPreference = 'Stop'

try {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

    $payload = $raw | ConvertFrom-Json
    $command = [string]$payload.tool_input.command
    if ([string]::IsNullOrWhiteSpace($command)) { exit 0 }

    # <patrón-de-comando-prohibido> — EDITAR: regex del comando que querés bloquear.
    $pattern = '(?i)<patron-de-comando-prohibido>'
    if ($command -notmatch $pattern) { exit 0 }

    $reason = @(
        "Repo contract: agents must not run this command.",
        "Command blocked: $command",
        "Ask the developer to run it. See AGENTS.md > Commands."
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
    [Console]::Error.WriteLine("block-forbidden-command hook error: $($_.Exception.Message)")
    exit 0
}
