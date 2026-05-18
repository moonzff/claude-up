@echo off
echo.
echo ================================================
echo   Claude_up - cognee Install
echo ================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-cognee.ps1" -Execute
echo.
pause
