@echo off
:: Claude_up Diagnostic CLI Launcher
:: 用法: run.bat <command>
:: 示例: run.bat doctor
::       run.bat deploy-dry-run

setlocal

set SCRIPT=%~dp0claude_app.ps1
set CMD=%~1

if "%CMD%"=="" (
    set CMD=help
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %CMD%
pause
