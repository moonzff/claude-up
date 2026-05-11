@echo off
chcp 65001 > nul
echo ============================================
echo  Letta 本地记忆服务器启动器
echo  Claude_up Phase 7-B
echo ============================================
echo.

REM ---- 检查 letta 是否已安装 ----
where letta > nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 letta 命令。请先执行安装：
    echo.
    echo   pip install letta
    echo   npm install -g letta-mcp-server
    echo.
    echo 安装完成后重新运行此脚本。
    pause
    exit /b 1
)

echo [OK] letta 已安装
echo.

REM ---- 检查端口 8283 是否已被占用 ----
netstat -ano | findstr ":8283" | findstr "LISTENING" > nul 2>&1
if not errorlevel 1 (
    echo [信息] Letta 服务可能已在运行（端口 8283 已被占用）
    echo 如需重启，请先在任务管理器中结束 letta 进程。
    echo.
    echo [状态] Letta 服务地址：http://localhost:8283
    echo [状态] Letta 管理界面：http://localhost:8283/ui（如有）
    pause
    exit /b 0
)

REM ---- 启动 Letta 服务器（后台窗口）----
echo [启动] 正在启动 Letta 服务器...
start "Letta Memory Server" cmd /k "letta server && echo. && echo [Letta] 服务已停止，按任意键关闭 && pause"

echo [等待] 服务启动中（5 秒）...
timeout /t 5 /nobreak > nul

echo.
echo ============================================
echo  Letta 服务已启动
echo  地址：http://localhost:8283
echo  现在可以打开 / 刷新 Claude 桌面应用
echo ============================================
echo.
echo 注意：关闭此窗口不会停止 Letta 服务。
echo 要停止服务，请关闭"Letta Memory Server"窗口
echo 或在任务管理器中结束 letta.exe 进程。
echo.
pause
