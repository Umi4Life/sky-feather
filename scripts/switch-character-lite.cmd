@echo off
REM Switch Cursor character using file copies only (no dot-sourced libs). Safer on locked-down Windows.
setlocal EnableExtensions
set "RAW=%~1"
if "%RAW%"=="" (
  echo Usage: switch-character-lite.cmd ^<character-id-or-alias^>
  exit /b 1
)

set "ID=%RAW%"
if /i "%ID%"=="feather" set "ID=sky-feather"
if /i "%ID%"=="sky" set "ID=sky-feather"
if /i "%ID%"=="default" set "ID=sky-feather"
if /i "%ID%"=="setsuna" set "ID=sumeragi-setsuna"
if /i "%ID%"=="architect" set "ID=sumeragi-setsuna"
if /i "%ID%"=="tsubaki" set "ID=aihara-tsubaki"
if /i "%ID%"=="pair" set "ID=aihara-tsubaki"
if /i "%ID%"=="arisu" set "ID=suzushima-arisu"
if /i "%ID%"=="lab" set "ID=suzushima-arisu"
if /i "%ID%"=="akane" set "ID=ousaka-akane"
if /i "%ID%"=="brainstorm" set "ID=ousaka-akane"
if /i "%ID%"=="kaede" set "ID=kujo-kaede"
if /i "%ID%"=="ops" set "ID=kujo-kaede"
if /i "%ID%"=="koboshi" set "ID=inohara-koboshi"
if /i "%ID%"=="automation" set "ID=inohara-koboshi"

set "ROOT=%USERPROFILE%\.cursor\sky-feather"
set "DROP=%ROOT%\skill-drops\%ID%.md"
set "BUNDLE=%ROOT%\bundles\%ID%.md"
set "SKILL=%USERPROFILE%\.cursor\skills\sky-feather-character\SKILL.md"

if not exist "%DROP%" (
  if not exist "%BUNDLE%" (
    echo error: no bundle for "%ID%". Run install-cursor-global first.
    exit /b 1
  )
  echo error: skill-drop missing for "%ID%". Re-run install-cursor-global or build-bundles.ps1.
  exit /b 1
)

if not exist "%USERPROFILE%\.cursor\skills\sky-feather-character" mkdir "%USERPROFILE%\.cursor\skills\sky-feather-character"
copy /Y "%DROP%" "%SKILL%" >nul
copy /Y "%BUNDLE%" "%ROOT%\active-bundle.md" >nul

powershell -NoProfile -ExecutionPolicy Bypass -Command "$m=@{version='3.2';active='%ID%';updatedAt=(Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')};$m|ConvertTo-Json|Set-Content -Path '%ROOT%\manifest.json' -Encoding utf8"

echo Switched active character to: %ID%
echo   %SKILL%
echo.
echo Start a new Cursor chat for reliable application.
