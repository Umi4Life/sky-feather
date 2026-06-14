# Install Sky Feather V3 global Claude Code personality (Windows PowerShell).
param(
    [string]$RepoPath
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\common.ps1')

$repoRoot = if ($RepoPath) { (Resolve-Path $RepoPath).Path } else { Get-SfRepoRoot }
$mirror = Get-SfClaudeMirror
$claudeMd = Get-SfClaudeMdPath
$bundlesDir = Join-Path $mirror 'bundles'
$config = Get-SfCharactersConfig
$defaultChar = $config.default
$mirrorHome = Get-SfClaudeMirrorHomeDisplay

Write-Host 'Installing Sky Feather V3.2 global Claude Code setup'
Write-Host "  Repo:      $repoRoot"
Write-Host "  Mirror:    $mirror"
Write-Host "  CLAUDE.md: $claudeMd"

New-Item -ItemType Directory -Force -Path $mirror | Out-Null

foreach ($item in @('CORE.md', 'characters', 'skills', 'examples')) {
    $src = Join-Path $repoRoot $item
    $dst = Join-Path $mirror $item
    if (Test-Path $src) {
        if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
        Copy-Item $src $dst -Recurse -Force
    }
}

$scriptsLib = Join-Path $mirror 'scripts-lib'
New-Item -ItemType Directory -Force -Path $scriptsLib | Out-Null
Copy-Item (Join-Path $PSScriptRoot 'lib\characters.json') (Join-Path $scriptsLib 'characters.json') -Force
Copy-Item (Join-Path $PSScriptRoot 'lib\claude-paths.json') (Join-Path $scriptsLib 'claude-paths.json') -Force

Build-SfAllBundles -RepoRoot $repoRoot -OutputDir $bundlesDir -MirrorHome $mirrorHome

$activeChar = $defaultChar
$manifestPath = Join-Path $mirror 'manifest.json'
if (Test-Path $manifestPath) {
    $existing = (Get-Content $manifestPath -Raw | ConvertFrom-Json).active
    if ($existing -and (Test-Path (Join-Path $bundlesDir "$existing.md"))) {
        $activeChar = $existing
    }
}

$activeBundle = Join-Path $mirror 'active-bundle.md'
Copy-Item (Join-Path $bundlesDir "$activeChar.md") $activeBundle -Force
Write-SfManifest -MirrorDir $mirror -ActiveId $activeChar
Write-SfClaudeFile -BundlePath $activeBundle

Install-SfClaudeCharacterSkill -RepoScriptsDir $PSScriptRoot
Sync-SfClaudeGlobalBin -RepoScriptsDir $PSScriptRoot

Write-Host ''
Write-Host 'Installed V3.2 materials:'
Write-Host "  $mirror\"
Write-Host "  $bundlesDir\"
Write-Host "  $activeBundle"
Write-Host "  $claudeMd"
Write-Host "  $(Join-Path (Get-SfClaudeCharacterSkillDir) 'SKILL.md')"
Write-Host "  $(Get-SfClaudeGlobalSwitchScriptPs1)"
Write-Host ''
Write-Host "Active character: $activeChar"

Write-SfClaudeNextSteps
