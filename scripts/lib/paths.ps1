# Resolve Cursor global paths (Windows PowerShell).

function Get-SfCursorHome {
    if ($env:CURSOR_HOME) {
        return $env:CURSOR_HOME
    }
    return Join-Path $env:USERPROFILE '.cursor'
}

function Get-SfRepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

function Get-SfScriptsDir {
    return (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

function Get-SfSkyFeatherMirror {
    return Join-Path (Get-SfCursorHome) 'sky-feather'
}

function Get-SfGlobalBinDir {
    return Join-Path (Get-SfSkyFeatherMirror) 'bin'
}

function Get-SfGlobalSwitchScriptPs1 {
    return Join-Path (Get-SfGlobalBinDir) 'switch-character.ps1'
}

function Get-SfGlobalSwitchScriptSh {
    return Join-Path (Get-SfGlobalBinDir) 'switch-character.sh'
}

function Get-SfSkillCharacterDir {
    return Join-Path (Get-SfCursorHome) 'skills\sky-feather-character'
}

function Get-SfLegacySkillDir {
    return Join-Path (Get-SfCursorHome) 'skills\sky-feather-soul'
}

function Get-SfCommandsDir {
    return Join-Path (Get-SfCursorHome) 'commands'
}

function Get-SfHermesHome {
    if ($env:HERMES_HOME) {
        return $env:HERMES_HOME
    }
    return Join-Path $env:USERPROFILE '.hermes'
}

function Get-SfHermesMirror {
    return Join-Path (Get-SfHermesHome) 'sky-feather'
}

function Get-SfHermesSoulPath {
    return Join-Path (Get-SfHermesHome) 'SOUL.md'
}

function Get-SfHermesSkillsDir {
    return Join-Path (Get-SfHermesHome) 'skills'
}

function Get-SfHermesBackupsDir {
    return Join-Path (Get-SfHermesHome) 'backups'
}
