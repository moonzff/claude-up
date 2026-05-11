# Claude_up Bootstrap Guide
**在新 Windows 机器上从零复现完整 Claude_up 环境**

---

## 前置条件

| 工具 | 最低版本 | 获取方式 |
|------|---------|---------|
| Windows | 10 / 11 | — |
| PowerShell | 5.1（系统自带）或 7.x | [下载 PS7](https://github.com/PowerShell/PowerShell/releases) |
| Node.js + npm | 18 LTS 或更高 | https://nodejs.org |
| Git | 任意现代版本 | https://git-scm.com |

验证工具可用性（在 PowerShell 中）：
```powershell
node --version   # 应输出 v18.x.x 或更高
npm --version
git --version
```

---

## 第一步：获取 Claude_up 工具包

**选项 A — 从 Git 克隆（推荐）**
```powershell
git clone <your-repo-url> D:\MoonzWorkspace\Claude_up
```

**选项 B — 从备份恢复**
将 `Claude_up` 目录整体复制到 `D:\MoonzWorkspace\Claude_up`。

验证：
```powershell
Test-Path "D:\MoonzWorkspace\Claude_up\ROADMAP.md"   # 应返回 True
```

---

## 第二步：部署核心配置到 `~/.claude/`

```powershell
cd D:\MoonzWorkspace\Claude_up

# 预览（不修改任何文件）
.\06-deployment-kit\install_claude_app.ps1

# 确认预览无误后，执行部署
.\06-deployment-kit\install_claude_app.ps1 -Execute
```

或双击文件资源管理器中的：
```
D:\MoonzWorkspace\Claude_up\06-deployment-kit\deploy_execute.bat
```

**按场景选择（可选）：**
```powershell
# 开发场景（追加 dev profile 到 CLAUDE.md）
.\06-deployment-kit\install_claude_app.ps1 -Execute -Profile dev

# 助理场景（追加 assistant profile 到 CLAUDE.md）
.\06-deployment-kit\install_claude_app.ps1 -Execute -Profile assistant
```

---

## 第三步：验证环境

```powershell
cd D:\MoonzWorkspace\Claude_up
.\cli\claude_app.ps1 doctor
```

全部 6/6 通过即为成功。常见问题：

| 错误 | 原因 | 修复 |
|------|------|------|
| `npx 未找到` | Node.js 未安装 | 安装 Node.js 后重试 |
| `settings.json 未部署` | 第二步未执行 | 运行 deploy_execute.bat |
| `CLAUDE.md 超过 200 行` | 追加 Profile 后超限 | 手动精简 CLAUDE.md |

---

## 第四步：注册 MCP 服务器（可选，Claude Code CLI 用户）

如果你使用 Claude Code CLI（`claude` 命令可用）：
```powershell
claude mcp add filesystem --scope user npx @modelcontextprotocol/server-filesystem D:\MoonzWorkspace
claude mcp add playwright --scope user npx @playwright/mcp@latest
claude mcp add context7  --scope user npx @upstash/context7-mcp@latest
```

> **Cowork 桌面版用户**：此步骤可跳过，MCP 已通过 settings.json 配置。

---

## 第五步：配置 API 密钥（环境变量）

settings.json 使用 `${env:ANTHROPIC_API_KEY}` 语法，密钥从系统环境变量读取。

在 Windows 系统环境变量中添加：
```
变量名: ANTHROPIC_API_KEY
变量值: sk-ant-...
```

路径：**系统属性 → 高级 → 环境变量 → 系统变量 → 新建**

验证：
```powershell
echo $Env:ANTHROPIC_API_KEY   # 应输出密钥（不为空）
```

---

## 完整检查清单

```
[ ] Node.js 18+ 已安装
[ ] Git 已安装
[ ] Claude_up 目录在 D:\MoonzWorkspace\Claude_up
[ ] deploy_execute.bat 已运行（[COPY] 输出确认）
[ ] .\cli\claude_app.ps1 doctor 全部通过（6/6）
[ ] ANTHROPIC_API_KEY 环境变量已设置
[ ] （可选）claude mcp add 命令已执行
```

---

## 目录结构速览

```
Claude_up/
├── 00-overview/        认知综合报告 v0.1 / v0.2
├── 01-global-config/   settings.json + CLAUDE.md 模板
├── 02-skills/          6 个 Skills (dev + assistant)
├── 04-hooks/           4 个 Hook 配置
├── 05-mcp/             MCP 服务器配置
├── 06-deployment-kit/  部署脚本（本文件所在目录）
│   ├── install_claude_app.ps1   参数化安装器
│   ├── deploy_execute.bat       一键部署
│   ├── deploy_dryrun.bat        预览部署
│   └── BOOTSTRAP.md             本文件
├── cli/
│   ├── claude_app.ps1   诊断 CLI
│   └── run.bat          启动器
└── 99-manifest/        CHANGELOG + VERSION
```

---

*生成于 2026-05-07 · Claude_up v0.6.0*
