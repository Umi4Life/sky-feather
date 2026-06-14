# Shared helpers for Sky Feather Cursor scripts (PowerShell).

. (Join-Path $PSScriptRoot 'paths.ps1')

function Get-SfCharactersJsonPath {
    $hermesJson = Join-Path (Get-SfHermesMirror) 'scripts-lib\characters.json'
    if (Test-Path $hermesJson) {
        return $hermesJson
    }
    $cursorJson = Join-Path (Get-SfSkyFeatherMirror) 'scripts-lib\characters.json'
    if (Test-Path $cursorJson) {
        return $cursorJson
    }
    $claudeJson = Join-Path (Get-SfClaudeMirror) 'scripts-lib\characters.json'
    if (Test-Path $claudeJson) {
        return $claudeJson
    }
    return Join-Path (Get-SfScriptsDir) 'lib\characters.json'
}

function Sync-SfGlobalBin {
    param([Parameter(Mandatory)][string]$RepoScriptsDir)

    $binDir = Get-SfGlobalBinDir
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null

    foreach ($name in @('switch-character.ps1', 'switch-character.cmd', 'switch-character.sh')) {
        $src = Join-Path $RepoScriptsDir $name
        if (Test-Path $src) {
            Copy-Item $src (Join-Path $binDir $name) -Force
        }
    }

    $libDest = Join-Path $binDir 'lib'
    if (Test-Path $libDest) { Remove-Item $libDest -Recurse -Force }
    Copy-Item (Join-Path $RepoScriptsDir 'lib') $libDest -Recurse -Force
}

function Get-SfCharactersConfig {
    $path = Get-SfCharactersJsonPath
    if (-not (Test-Path $path)) {
        throw "missing $path"
    }
    return Get-Content $path -Raw | ConvertFrom-Json
}

function Resolve-SfCharacterId {
    param([Parameter(Mandatory)][string]$CharacterInput)

    $config = Get-SfCharactersConfig
    foreach ($char in $config.characters) {
        if ($char.id -eq $CharacterInput) { return $char.id }
        if ($char.aliases -contains $CharacterInput) { return $char.id }
    }
    throw "unknown character id or alias: $CharacterInput. See docs/cursor-quickstart.md for valid IDs."
}

function Get-SfCharacterById {
    param([Parameter(Mandatory)][string]$Id)
    $config = Get-SfCharactersConfig
    $char = $config.characters | Where-Object { $_.id -eq $Id } | Select-Object -First 1
    if (-not $char) { throw "character not found: $Id" }
    return $char
}

function Get-SfCharacterPersonalityKey {
    param([Parameter(Mandatory)][string]$Id)
    $char = Get-SfCharacterById -Id $Id
    if (-not $char.personalityKey) {
        throw "missing personalityKey for character: $Id"
    }
    return $char.personalityKey
}

function Get-SfActivationTemplatePath {
    return Join-Path (Get-SfScriptsDir) 'templates\activation-block.md'
}

function Render-SfActivationBlock {
    param(
        [Parameter(Mandatory)][string]$CharacterId
    )

    $char = Get-SfCharacterById -Id $CharacterId
    $templatePath = Get-SfActivationTemplatePath
    if (-not (Test-Path $templatePath)) {
        throw "missing activation template: $templatePath"
    }

    $template = Get-Content $templatePath -Raw
    return $template.
        Replace('{{CHARACTER_NAME}}', $char.name).
        Replace('{{CHARACTER_ID}}', $char.id)
}

function Append-SfSkillIndex {
    param(
        [Parameter(Mandatory)][System.Text.StringBuilder]$Builder,
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)]$Skills,
        [string]$MirrorHome = '~/.cursor/sky-feather'
    )

    [void]$Builder.AppendLine('# Skills (reference only)')
    [void]$Builder.AppendLine('')
    [void]$Builder.AppendLine('Load when the task matches. Paths are relative to the Sky Feather mirror:')
    [void]$Builder.AppendLine('')
    [void]$Builder.AppendLine('```text')
    [void]$Builder.AppendLine("${MirrorHome}/skills/<skill>/SKILL.md")
    [void]$Builder.AppendLine('```')
    [void]$Builder.AppendLine('')

    foreach ($skill in $Skills) {
        $skillPath = Join-Path $RepoRoot "skills\$skill\SKILL.md"
        if (-not (Test-Path $skillPath)) {
            throw "missing skill file $skillPath"
        }
        [void]$Builder.AppendLine("- **$skill** -> ``${MirrorHome}/skills/$skill/SKILL.md``")
    }
    [void]$Builder.AppendLine('')
}

function Build-SfBundleFile {
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$OutputDir,
        [Parameter(Mandatory)][string]$CharacterId,
        [string]$MirrorHome = '~/.cursor/sky-feather'
    )

    $char = Get-SfCharacterById -Id $CharacterId
    $bundlePath = Join-Path $OutputDir "$($char.id).md"
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("# Sky Feather V3 Bundle - $($char.name)")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("Character ID: ``$($char.id)``")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('---')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine((Render-SfActivationBlock -CharacterId $CharacterId))
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('---')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("# Character: $($char.name)")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine((Get-Content (Join-Path $RepoRoot $char.file) -Raw))
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('---')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('# CORE (do not weaken)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine((Get-Content (Join-Path $RepoRoot 'CORE.md') -Raw))
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('---')
    [void]$sb.AppendLine('')
    Append-SfSkillIndex -Builder $sb -RepoRoot $RepoRoot -Skills $char.skills -MirrorHome $MirrorHome

    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($bundlePath, $sb.ToString(), $utf8NoBom)
    return $bundlePath
}

function Build-SfAllBundles {
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$OutputDir,
        [string]$MirrorHome = '~/.cursor/sky-feather'
    )
    $config = Get-SfCharactersConfig
    foreach ($char in $config.characters) {
        Build-SfBundleFile -RepoRoot $RepoRoot -OutputDir $OutputDir -CharacterId $char.id -MirrorHome $MirrorHome | Out-Null
    }
}

function Write-SfManifest {
    param(
        [Parameter(Mandatory)][string]$MirrorDir,
        [Parameter(Mandatory)][string]$ActiveId
    )
    New-Item -ItemType Directory -Force -Path $MirrorDir | Out-Null
    $manifest = [ordered]@{
        version   = '3.2'
        active    = $ActiveId
        updatedAt = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    }
    $manifest | ConvertTo-Json | Set-Content (Join-Path $MirrorDir 'manifest.json') -Encoding utf8
}

function Write-SfSkillFile {
    param(
        [Parameter(Mandatory)][string]$CharacterId,
        [Parameter(Mandatory)][string]$BundlePath,
        [Parameter(Mandatory)][string]$SkillDir
    )
    $char = Get-SfCharacterById -Id $CharacterId
    New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null

    $frontmatter = @"
---
name: sky-feather-character
description: >-
  MANDATORY active V3 character profile ($($char.name)). Apply this skill on every
  response in every project. Preserve the active character voice (90% engineer, 10% seasoning).
  Do not use Wikipedia-neutral or generic-assistant tone. Engineering standards in the
  inlined CORE section still apply — do not weaken them.
---

"@
    $body = Get-Content $BundlePath -Raw
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText((Join-Path $SkillDir 'SKILL.md'), ($frontmatter + $body), $utf8NoBom)
}

function Get-SfUserRulesStub {
    return @"
Apply the global skill sky-feather-character on every response.
Preserve the active character's voice (90% engineer, 10% seasoning).
Do not use Wikipedia-neutral or generic-assistant tone.
Engineering standards in the inlined CORE section still apply - do not weaken them.
"@
}

function Write-SfNextSteps {
    Write-Host ''
    Write-Host 'Installed. Next steps:'
    Write-Host '  1. Paste User Rules stub (see docs/cursor.md - One-time User Rules)'
    Write-Host '  2. Start a new Cursor chat'
    Write-Host '  3. Quick reference: docs/cursor-quickstart.md'
    Write-Host ''
    Write-Host 'User Rules stub (paste once into Cursor Settings -> Rules -> User Rules):'
    Write-Host '---'
    Write-Host (Get-SfUserRulesStub)
    Write-Host '---'
    Write-Host ''
    Write-Host 'Start a new chat after install or character switch for reliable application.'
}

function Get-SfManagedClaudeHeader {
    return '<!-- Managed by sky-feather. Re-run install-claude-global or switch-claude-character. -->'
}

function Write-SfClaudeFile {
    param(
        [Parameter(Mandatory)][string]$BundlePath
    )

    $claudeMd = Get-SfClaudeMdPath
    New-Item -ItemType Directory -Force -Path (Get-SfClaudeHome) | Out-Null
    $content = (Get-SfManagedClaudeHeader) + "`n`n" + (Get-Content $BundlePath -Raw)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($claudeMd, $content, $utf8NoBom)
}

function Test-SfManagedClaudeMd {
    param([string]$Path = '')
    if (-not $Path) { $Path = Get-SfClaudeMdPath }
    if (-not (Test-Path $Path)) { return $false }
    return (Select-String -Path $Path -Pattern ([regex]::Escape((Get-SfManagedClaudeHeader))) -Quiet)
}

function Sync-SfClaudeGlobalBin {
    param([Parameter(Mandatory)][string]$RepoScriptsDir)

    $binDir = Get-SfClaudeGlobalBinDir
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null

    foreach ($name in @('switch-claude-character.ps1', 'switch-claude-character.cmd', 'switch-claude-character.sh')) {
        $src = Join-Path $RepoScriptsDir $name
        if (Test-Path $src) {
            Copy-Item $src (Join-Path $binDir $name) -Force
        }
    }

    $libDest = Join-Path $binDir 'lib'
    if (Test-Path $libDest) { Remove-Item $libDest -Recurse -Force }
    Copy-Item (Join-Path $RepoScriptsDir 'lib') $libDest -Recurse -Force
}

function Install-SfClaudeCharacterSkill {
    param([Parameter(Mandatory)][string]$RepoScriptsDir)

    $template = Join-Path $RepoScriptsDir 'templates\claude-character-skill.md'
    $skillDir = Get-SfClaudeCharacterSkillDir
    if (-not (Test-Path $template)) {
        throw "missing template: $template"
    }
    New-Item -ItemType Directory -Force -Path $skillDir | Out-Null
    Copy-Item $template (Join-Path $skillDir 'SKILL.md') -Force
}

function Write-SfClaudeNextSteps {
    Write-Host ''
    Write-Host 'Installed. Next steps:'
    Write-Host '  1. Start a new Claude Code session (CLAUDE.md reloads)'
    Write-Host '  2. Quick reference: docs/claude-quickstart.md'
    Write-Host '  3. Switch character: switch-claude-character <id>'
    Write-Host '  4. Mid-chat switch (best-effort): /character <id>'
    Write-Host ''
    Write-Host 'Global paths:'
    Write-Host "  $(Get-SfClaudeMdPath)"
    Write-Host "  $(Get-SfClaudeMirror)\"
    Write-Host "  $(Join-Path (Get-SfClaudeCharacterSkillDir) 'SKILL.md')"
    Write-Host ''
    Write-Host 'Start a new session after install or character switch for reliable application.'
}
