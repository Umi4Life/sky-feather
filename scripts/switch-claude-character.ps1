# Switch active global Claude Code character profile (Windows PowerShell).
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Character
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\common.ps1')

$charId = Resolve-SfCharacterId -CharacterInput $Character
$mirror = Get-SfClaudeMirror
$bundlesDir = Join-Path $mirror 'bundles'
$bundle = Join-Path $bundlesDir "$charId.md"

if (-not (Test-Path $bundle)) {
    throw "bundle not found: $bundle. Run install-claude-global.ps1 first."
}

$activeBundle = Join-Path $mirror 'active-bundle.md'
Copy-Item $bundle $activeBundle -Force
Write-SfManifest -MirrorDir $mirror -ActiveId $charId
$claudeDrop = Join-Path $mirror 'claude-drops' "$charId.md"
Write-SfClaudeFile -BundlePath $activeBundle -ClaudeDropPath $claudeDrop

$char = Get-SfCharacterById -Id $charId
Write-Host "Switched active character to: $($char.name) ($charId)"
Write-Host "  $(Get-SfClaudeMdPath)"
Write-Host ''
Write-Host 'Start a new Claude Code session for reliable application.'
