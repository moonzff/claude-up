@echo off
chcp 65001 >nul
echo.
echo ================================================
echo   Claude_up - codegraph Install
echo ================================================
echo.
echo Step 1: Installing codegraph globally...
npm install -g @colbymchenry/codegraph
if %errorlevel% neq 0 (
    echo [ERROR] npm install failed.
    pause
    exit /b 1
)
echo.
echo Step 2: Running interactive configurator (adds MCP to Claude Code)...
npx @colbymchenry/codegraph
echo.
echo ================================================
echo   DONE
echo.
echo   Next: cd into each project and run:
echo     codegraph init -i
echo ================================================
echo.
pause
