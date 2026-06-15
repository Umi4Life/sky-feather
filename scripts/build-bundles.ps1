# Build flat character bundles into a target directory.
param(
    [string]$OutputDir
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\common.ps1')

$repoRoot = Get-SfRepoRoot
if (-not $OutputDir) {
    $OutputDir = Join-Path (Get-SfSkyFeatherMirror) 'bundles'
}

Write-Host "Building bundles from: $repoRoot"
Write-Host "Output directory: $OutputDir"

Build-SfAllBundles -RepoRoot $repoRoot -OutputDir $OutputDir

$config = Get-SfCharactersConfig
$mirrorRoot = Split-Path $OutputDir -Parent
Write-Host 'Built bundles:'
foreach ($char in $config.characters) {
    Write-Host "  $(Join-Path $OutputDir "$($char.id).md")"
}
Write-Host 'Built skill drops:'
foreach ($char in $config.characters) {
    Write-Host "  $(Join-Path $mirrorRoot "skill-drops\$($char.id).md")"
}
Write-Host 'Built claude drops:'
foreach ($char in $config.characters) {
    Write-Host "  $(Join-Path $mirrorRoot "claude-drops\$($char.id).md")"
}
