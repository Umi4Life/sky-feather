# Switch active global Cursor character profile (Windows PowerShell).
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Character
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\common.ps1')

$charId = Resolve-SfCharacterId -CharacterInput $Character
$mirror = Get-SfSkyFeatherMirror
$bundlesDir = Join-Path $mirror 'bundles'
$bundle = Join-Path $bundlesDir "$charId.md"
$skillDir = Get-SfSkillCharacterDir

if (-not (Test-Path $bundle)) {
    throw "bundle not found: $bundle. Run install-cursor-global.ps1 first."
}

$activeBundle = Join-Path $mirror 'active-bundle.md'
Copy-Item $bundle $activeBundle -Force
Write-SfManifest -MirrorDir $mirror -ActiveId $charId
Write-SfSkillFile -CharacterId $charId -BundlePath $activeBundle -SkillDir $skillDir

$char = Get-SfCharacterById -Id $charId
Write-Host "Switched active character to: $($char.name) ($charId)"
Write-Host "  $(Join-Path $skillDir 'SKILL.md')"
Write-Host ''
Write-Host 'Start a new Cursor chat for reliable application.'
