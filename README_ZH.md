# Claude_up

> **可复现、可审计的 Claude Code 环境治理工具包。**
> 双场景覆盖：深度软件工程 + 个人数字助理。

[![版本](https://img.shields.io/badge/版本-v1.0.0-blue)](99-manifest/CHANGELOG.md)
[![许可证](https://img.shields.io/badge/许可证-MIT-green)](LICENSE)
[![平台](https://img.shields.io/badge/平台-Windows%2011%20%2B%20WSL2-lightgrey)](01-global-config/)

[English →](README.md)

---

## 是什么？

Claude_up 是一套针对 [Claude Code](https://claude.ai/code) 的个人环境治理工具包。它让你拥有一套**版本化、可移植、干跑安全**的配置，可以在几分钟内部署到任意新机器。

把它理解为你的 Claude Code dotfiles——但内置了技能库、持久记忆系统、Hook 模板、MCP 配置和诊断 CLI。

**两种场景开箱即用：**
- 🛠️ **工程开发** — 编码、TDD、代码审查、安全审计、API 设计、调试
- 🧠 **个人助理** — 研究归档、会议纪要、周复盘、知识管理

---

## 核心能力

### 全局 Skills（02-skills/ · 每次会话默认激活）

8 个 Skills 覆盖双场景，每次会话自动可用：

| 类别 | Skills |
|------|--------|
| Dev | `grill-plan`（需求澄清 v2 Ouroboros 演化循环）· `diagnose` · `dual-environment-workflow` |
| Assistant | `research-object-archive` · `summarize-meeting` · `weekly-review` · `memory-update` |

### 技能库（10-skill-library/ · 按需加载）

10 个专项 Skill，只在需要时加载，不占默认上下文：

| Skill | 触发场景 |
|-------|---------|
| `sp-brainstorming` | 写代码前——澄清设计方向 |
| `sp-writing-plans` | 设计确认后——编写可执行任务计划 |
| `sp-executing-plans` | 执行计划，两阶段 Review（需要 CLI）|
| `sp-tdd` | 测试驱动开发循环 |
| `systematic-debugging` | 四阶段系统化排查（定位→分析→假设→修复）|
| `verification-before-completion` | 声称完成前必须先验证，证据先行 |
| `code-review` | 六维度代码审查（正确性/安全/性能/可维护/测试/架构）|
| `security-audit` | OWASP Top 10 + Node.js + AWS 安全扫描 |
| `api-design` | REST API 设计规范（Node.js）|
| `task-master` | 大项目跨会话任务持久化，防止执行循环（需要 CLI）|

### 记忆系统（08-memory/ · 四层架构）

跨会话的持久知识积累——无需外部服务，纯文件实现：

```
core/        ← 每次会话自动加载（4个块，字符限制）：角色/用户/项目/技术栈
working/     ← 项目级详情，进入具体项目时按需读取
semantic/    ← 提炼的规律模式 + 约定惯例（含置信度评分）
archive/     ← 只追加的日志：决策/教训/事件
```

灵感来源：[Letta](https://github.com/letta-ai/letta) 记忆块架构和 [agentmemory](https://github.com/rohitg00/agentmemory) 的置信度/进化理念——用纯 Markdown 文件实现，零依赖。

记忆系统特性（v2.0）：
- **置信度评分**（0.0–1.0）：每条教训和规律有置信度，被验证时增强
- **记忆进化**：旧知识被新信息取代时用 `superseded_by` 标记，保留进化历史
- **矛盾检测**：写入新记忆前自动检查是否与已有知识矛盾
- **规律蒸馏**：同类教训出现 2+ 次时提炼为 semantic/ 层规律

### Hooks（04-hooks/ · 确定性行为）

4 个 Hook 保证工作流一致性：

| Hook | 触发时机 | 行为 |
|------|---------|------|
| `pre-bash-audit` | Bash 命令前 | 记录命令到 audit.log |
| `post-write-format` | 写文件后 | 运行 prettier 格式化 |
| `stop-session-summary` | 会话结束 | 写入 session-log.txt |
| `post-write-research` | 写研究类文件后 | 提示 ROA 归档 |

### MCP 服务器（05-mcp/）

5 个 MCP 服务器配置（需要 Claude Code CLI）：

| MCP | 状态 | 用途 |
|-----|------|------|
| `filesystem` | ✅ 已激活 | 本地文件访问 |
| `playwright` | ✅ 已激活 | 浏览器自动化 |
| `context7` | ✅ 已激活 | 实时库文档查询 |
| `github` | ⚙️ 需设置 `GITHUB_TOKEN` 环境变量 | GitHub API |
| `letta` | ⚙️ 需本地 Letta 服务 | （可选）Letta 记忆 MCP |

### 部署套件（06-deployment-kit/）

安全的干跑优先安装器，支持场景化部署：

```powershell
# 预览变更（默认，不写入）
.\06-deployment-kit\install_claude_app.ps1

# 确认后执行
.\06-deployment-kit\install_claude_app.ps1 -Execute -Profile dev
# Profile 选项：dev | assistant | full
```

---

## 快速开始

### 前置条件
- Windows 11 + PowerShell 7
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) 已安装
- Node.js ≥ 18

### 1. 克隆

```powershell
git clone https://github.com/moonzff/claude-up.git D:\YourWorkspace\Claude_up
cd D:\YourWorkspace\Claude_up
```

### 2. 初始化个人记忆

```powershell
# 复制模板并填入个人信息
Copy-Item 08-memory\templates\human.template.md    08-memory\core\human.md
Copy-Item 08-memory\templates\projects.template.md 08-memory\core\projects.md
# 编辑这两个文件，填入你的信息
```

### 3. 部署配置

```powershell
# 先干跑看预览
.\06-deployment-kit\install_claude_app.ps1

# 确认无误后执行
.\06-deployment-kit\install_claude_app.ps1 -Execute -Profile full
```

### 4. 验证

```powershell
.\cli\claude_app.ps1 doctor
```

---

## 目录结构

```
Claude_up/
├── 00-overview/          # 研究文档和架构综合规划
├── 01-global-config/     # settings.json + CLAUDE.md 模板
│   └── windows-claude/
├── 02-skills/            # 全局激活 Skills（dev/ + assistant/）
├── 03-commands/          # 斜杠命令模板
├── 04-hooks/             # Hook 配置（dev/ + assistant/）
├── 05-mcp/               # MCP 服务器配置与激活指南
├── 06-deployment-kit/    # 安装器、引导文档、部署脚本
├── 08-memory/            # 四层记忆系统
│   ├── core/             # 每次加载的块（persona/stack 公开，human/projects 在 .gitignore）
│   ├── working/          # 项目级上下文（.gitignore）
│   ├── semantic/         # 提炼规律 + 约定惯例
│   ├── archive/          # 只追加的决策/教训/事件日志
│   └── templates/        # gitignore 文件的起始模板
├── 10-skill-library/     # 按需技能库（INDEX.md + 10 个 Skills）
├── 99-manifest/          # CHANGELOG、VERSION
├── cli/                  # 诊断 CLI（doctor/mcp-check/skill-list...）
└── tooling/              # 周边工具（ccusage、task-master 指南）
```

---

## 设计原则

1. **先想后做** — 执行任何写操作前，先检查现有状态
2. **简单优先** — 优先用已有脚本/模板，而非引入新依赖
3. **外科手术式改动** — 只动当前任务需要的文件
4. **干跑优先** — 批量操作先预演报告，确认后再执行
5. **密钥绝不在文档里** — 配置用 `${env:VAR}` 占位符，永远不硬编码
6. **零外部服务依赖** — 核心功能无需运行任何外部服务器

---

## 生态参考来源

通过调研并选择性吸收以下项目的设计理念：

| 项目 | 吸收的内容 |
|------|-----------|
| [obra/superpowers](https://github.com/obra/superpowers) | sp-brainstorming/writing-plans/executing-plans 方法论 |
| [Letta](https://github.com/letta-ai/letta) | 三层记忆块架构 |
| [agentmemory](https://github.com/rohitg00/agentmemory) | 四层记忆、置信度评分、记忆进化 |
| [jnMetaCode/superpowers-zh](https://github.com/jnMetaCode/superpowers-zh) | systematic-debugging、verification-before-completion |
| [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Skill 设计模式和社区最佳实践 |

---

## 周边工具

以下工具与 Claude_up 配合使用，但不包含在本仓库中：

- **[ccusage](tooling/ccusage.md)** — Token 用量和成本追踪（`npx ccusage daily`）
- **[claude-task-master](10-skill-library/dev/task-master/SKILL.md)** — 大项目跨会话任务持久化

---

## 许可证

[MIT](LICENSE) © 2026 Moonz
