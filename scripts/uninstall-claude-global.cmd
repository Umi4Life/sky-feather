@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall-claude-global.ps1" %*
