---
name: dual-environment-workflow
description: Route tasks to the correct environment (Windows PowerShell vs WSL2 Linux) based on task type. Trigger when user asks about running commands, file operations, or development tasks in the Windows/WSL2 dual environment.
---

# Dual Environment Workflow

在 Windows + WSL2 双环境下，将任务路由到正确的执行环境。

## 环境说明

```
Windows 宿主机
├── 文件系统：D:\MoonzWorkspace\（主工作目录）
├── 工具：PowerShell 7、File Explorer、GUI 工具
├── Claude Code：在 Windows 终端中运行
└── WSL2 Ubuntu
    ├── 挂载点：/mnt/d/MoonzWorkspace/（同一目录）
    ├── 工具：bash、git、node、python、npm
    └── 适合：Unix 工具链、脚本、CI 环境模拟
```

## 路由规则

### 用 Windows PowerShell 的场景

- 文件管理（`Copy-Item`、`Move-Item`、`New-Item`）
- 部署脚本（`.ps1` 文件，操作 `%USERPROFILE%` 路径）
- 调用 Windows 原生工具（注册表、系统配置）
- Claude Code CLI（`claude` 命令）
- 需要访问 Windows 路径 `C:\` 或 `D:\` 的操作

### 用 WSL2 Linux 的场景

- Git 操作（在项目目录下）
- Node.js / npm / npx 构建任务
- Python 脚本执行
- Unix 管道命令（`grep | awk | sed`）
- Docker 容器操作
- 模拟 CI/CD 环境

### 两者都可以的场景

- 读取文件内容（工具直接读，不走终端）
- 搜索代码（Grep 工具）
- 查看目录（Glob 工具）

## 路径对应关系

| Windows 路径 | WSL2 路径 |
|-------------|----------|
| `D:\MoonzWorkspace\` | `/mnt/d/MoonzWorkspace/` |
| `C:\Users\admin\` | `/mnt/c/Users/admin/` |
| `D:\MoonzWorkspace\Claude_up\` | `/mnt/d/MoonzWorkspace/Claude_up/` |

## 常用工作流

### 新项目初始化

```powershell
# Windows：创建目录
New-Item -ItemType Directory -Path "D:\MoonzWorkspace\MyProject"

# WSL2：初始化 git 和依赖
cd /mnt/d/MoonzWorkspace/MyProject
git init
npm init -y
```

### 部署配置（只用 PowerShell）

```powershell
# 总是用 PowerShell 操作 ~/.claude/ 和 %USERPROFILE%
Copy-Item "D:\MoonzWorkspace\Claude_up\01-global-config\windows-claude\settings.json" `
          "$env:USERPROFILE\.claude\settings.json" -Force
```

### 运行测试（WSL2）

```bash
# 测试在 Linux 环境中运行，确保 CI 一致性
cd /mnt/d/MoonzWorkspace/MyProject
npm test
```

## 故障排查

**问题：WSL2 中修改文件后 Windows 看不到更新**
→ 正常现象，刷新 File Explorer 或重新读取即可。两边操作的是同一文件。

**问题：WSL2 中 npm install 很慢**
→ 如果项目在 `/mnt/d/` 下，是跨文件系统 I/O 导致。考虑把 `node_modules` 放在 WSL2 本地目录（`~/projects/`），用软链接或直接在 WSL2 文件系统工作。

**问题：PowerShell 执行策略阻止脚本运行**
→ 使用 `-ExecutionPolicy Bypass` 参数，或以管理员身份运行：
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\script.ps1
```
