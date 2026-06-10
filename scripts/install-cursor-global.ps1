# Install Sky Feather V3 global Cursor personality (Windows PowerShell).
param(
    [string]$RepoPath
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\common.ps1')

$repoRoot = if ($RepoPath) { (Resolve-Path $RepoPath).Path } else { Get-SfRepoRoot }
$mirror = Get-SfSkyFeatherMirror
$skillDir = Get-SfSkillCharacterDir
$commandsDir = Get-SfCommandsDir
$bundlesDir = Join-Path $mirror 'bundles'
$config = Get-SfCharactersConfig
$defaultChar = $config.default

Write-Host 'Installing Sky Feather V3.2 global Cursor setup'
Write-Host "  Repo:   $repoRoot"
Write-Host "  Mirror: $mirror"
Write-Host "  Skill:  $skillDir"

$legacySkill = Get-SfLegacySkillDir
if (Test-Path $legacySkill) {
    Write-Host "Removing legacy skill: $legacySkill"
    Remove-Item $legacySkill -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $mirror, $skillDir, $commandsDir | Out-Null

foreach ($item in @('CORE.md', 'SOUL.md', 'characters', 'skills', 'examples')) {
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
Copy-Item (Join-Path $PSScriptRoot 'lib\cursor-paths.json') (Join-Path $scriptsLib 'cursor-paths.json') -Force

Build-SfAllBundles -RepoRoot $repoRoot -OutputDir $bundlesDir

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
Write-SfSkillFile -CharacterId $activeChar -BundlePath $activeBundle -SkillDir $skillDir

$commandTemplate = Join-Path $PSScriptRoot 'templates\character-command.md'
Copy-Item $commandTemplate (Join-Path $commandsDir 'character.md') -Force

Sync-SfGlobalBin -RepoScriptsDir $PSScriptRoot

Write-Host ''
Write-Host 'Installed V3.2 materials:'
Write-Host "  $mirror\"
Write-Host "  $bundlesDir\"
Write-Host "  $activeBundle"
Write-Host "  $(Join-Path $skillDir 'SKILL.md')"
Write-Host "  $(Join-Path $commandsDir 'character.md')"
Write-Host "  $(Get-SfGlobalSwitchScriptPs1)"
Write-Host ''
Write-Host "Active character: $activeChar"

Write-SfNextSteps
