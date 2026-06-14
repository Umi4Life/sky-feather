# Uninstall / prune Sky Feather global Claude Code artifacts.
param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\common.ps1')

function Remove-SfPath {
    param([string]$Path)
    if (Test-Path $Path) {
        if ($DryRun) {
            Write-Host "would remove: $Path"
        } else {
            Remove-Item $Path -Recurse -Force
            Write-Host "removed: $Path"
        }
    }
}

Remove-SfPath (Get-SfClaudeMirror)
Remove-SfPath (Get-SfClaudeCharacterSkillDir)

if (Test-SfManagedClaudeMd) {
    Remove-SfPath (Get-SfClaudeMdPath)
} else {
    Write-Host "skipped (not managed by sky-feather): $(Get-SfClaudeMdPath)"
}

Write-Host ''
if ($DryRun) {
    Write-Host 'Dry run complete. No files deleted.'
} else {
    Write-Host 'Uninstall complete.'
}

Write-Host @'

Manual step: if you customized ~/.claude/CLAUDE.md before install, review it after uninstall.
Start a new Claude Code session if you removed managed CLAUDE.md.
'@
