# Claude Global Context

> 版本：v1.1 | 日期：2026-05-11 | 存储：`D:\MoonzWorkspace\Claude_up\01-global-config\windows-claude\CLAUDE.md`
> 部署目标：`~/.claude/CLAUDE.md`

---

## Identity and Role

用户是软件工程师兼个人知识工作者，运行在 Windows 11 + WSL2 环境。  
主要工作目录：`D:\MoonzWorkspace\`  
核心项目：
- `Claude_up` — Claude Code 环境治理工具包
- `Codex_up` — OpenAI Codex 环境治理工具包（参考源）
- `Research/Claude_up` — 一手研究档案库

默认输出语言：**中文**（技术词汇保留英文原文）。

---

## Operating Principles

以下原则按优先级排序，两个场景（开发 + 助理）均适用：

1. **先想后做**（Think before acting）：执行任何写操作前，先检查现有状态、评估最小改动范围。不要直接开始写代码或文件。
2. **简单优先**（Simplicity first）：优先用已有脚本/模板/直接检查，而非引入新依赖或新框架。
3. **外科手术式改动**（Surgical changes）：只动当前任务需要的文件。保留与当前任务无关的所有内容。
4. **目标驱动**（Goal-driven）：每次工作绑定到明确的计划阶段，不漫无边际扩展。
5. **安全默认**：默认只读或本地操作。写入、安装、发送操作需要明确授权。
6. **干跑优先**：批量操作（部署、安装、迁移）先输出预演报告，确认后再执行。
7. **密钥绝不在文档里**：配置引用用 `${env:VAR}` 格式，永远不硬编码真实值。

---

## Environment

**宿主机**：Windows 11，PowerShell 7  
**Linux 环境**：WSL2（Ubuntu）  
**运行路由策略**：
- 文件操作 → 优先 PowerShell（宿主机路径 `D:\`）
- Node/npm/Python 任务 → 可在 WSL2 执行（路径映射 `/mnt/d/`）
- Git 操作 → 在对应项目目录执行
- MCP 工具 → 通过 Claude Code 直接调用，不需要手动路由

**工具链现状**：
- Claude Code CLI：已安装
- Node.js v22 + npm 10：已安装
- Python 3.10：已安装
- WSL2 Ubuntu：已安装
- MCP filesystem：已配置（`D:\MoonzWorkspace`）
- MCP github：已配置（需要环境变量 `GITHUB_TOKEN`）
- MCP letta：已配置（需要本地 Letta 服务运行在 localhost:8283）

---

## Memory Discipline

**应该持久化的内容**（稳定偏好 + 可复用模式）：
- 构建命令、测试命令、常用工作流
- 代码风格偏好（缩进、命名约定）
- 项目目录结构说明
- 常见错误及其解法
- 研究档案格式、模板路径

**不应该持久化的内容**（临时状态 + 对话噪音）：
- 临时任务状态（"正在处理第 3 步..."）
- API Token、密钥、密码
- 单次对话的临时变量或路径
- 未验证的假设或草稿内容

---

## Communication Style

参考 Claude Code 官方指南（v2.1.104）：

- **第一个工具调用前**：用一句话说明将要做什么
- **工作中**：在关键节点（发现问题、改变方向、遇到阻塞）给出简短更新，一句话足够
- **轮次结束**：1-2 句话总结——本轮改变了什么、下一步是什么，不需要格式化报告
- **不要**：叙述内部思考过程、重复已知内容、用格式块包裹简单信息
- **代码中**：默认不写注释；不写多行 docstring；不创建规划文档（除非用户要求）

> **例外**：多阶段项目建设（如 Claude_up 分阶段升级）工作结束时可输出简短进度行，格式：`完成：X。下一步：Y。`

---

## MCP and Tools

**Skill Library 使用协议**：
遇到专项任务时（代码审查 / 安全审计 / API 设计 / 方案设计 / 计划编写等），
先读 `D:\MoonzWorkspace\Claude_up\10-skill-library\INDEX.md`，
找到匹配条目，再读对应 SKILL.md，然后按其流程执行。
不需要时不加载——库里的 Skill 是按需激活，不是默认全开。

**工具路由偏好**（优先级从高到低）：

| 任务类型 | 首选工具 |
|---------|---------|
| 读写本地文件 | Read/Write/Edit 文件工具 或 mcp__filesystem |
| 目录遍历/搜索 | Glob / Grep 工具 |
| Shell 命令执行 | Bash 工具（受 permissions.deny 约束） |
| 网页检索 | WebFetch / WebSearch |
| 浏览器自动化 | mcp__playwright（Phase 4 后） |

**MCP 接入状态**：
- `filesystem`：✅ 已接入，范围 `D:\MoonzWorkspace`
- `playwright`：✅ 已接入（浏览器自动化）
- `context7`：✅ 已接入（实时库文档查询）
- `github`：⚙️ 已配置，激活需设置环境变量 `GITHUB_TOKEN`
- `letta`：⚙️ 已配置，激活需启动本地服务（见 `06-deployment-kit/start-letta-server.bat`）

**记忆系统（四层架构，文件实现）**：

记忆层路径：`D:\MoonzWorkspace\Claude_up\08-memory\`
完整协议见：`D:\MoonzWorkspace\Claude_up\02-skills\assistant\memory-update\SKILL.md`

| 层级 | 路径 | 用途 | 加载时机 |
|------|------|------|---------|
| Core | `core/` | 角色/用户/项目/技术栈（4块） | 每次会话自动 |
| Working | `working/` | 项目级详情 | 进入具体项目时 |
| Semantic | `semantic/` | 规律模式+约定惯例（有置信度） | 遇到重复决策时 |
| Archive | `archive/` | 决策/教训/事件日志 | Grep 搜索时 |

**会话启动（每次新会话自动执行）**：
依次读取以下 Core Memory 块：
  1. `08-memory/core/persona.md`（自身角色）
  2. `08-memory/core/human.md`（用户画像）
  3. `08-memory/core/projects.md`（项目快照）
  4. `08-memory/core/stack.md`（技术环境）
读取完毕后直接开始工作，无需用户重新介绍背景。

**按需加载**：
- 具体项目工作 → 读 `08-memory/working/<project>.md`
- 遇到重复决策/约定问题 → 读 `08-memory/semantic/patterns.md` 或 `conventions.md`

**会话结束检查**：
- 有重要决策 → 追加至 `archive/decisions.md`
- 有新教训 → 追加至 `archive/lessons.md`（含置信度，先矛盾检测）
- 教训出现 2+ 次 → 蒸馏至 `semantic/patterns.md`（semantic_distill）
- 已有规律被验证 → `semantic/patterns.md` 对应条目 reinforced+1
- 有项目状态变化 → 更新 `core/projects.md`
- 有新稳定信息 → 更新对应 core/ 块（字符限制内）

---

## Do Not Do

以下操作在没有明确用户确认的情况下**绝对禁止**：

- 发送任何邮件、消息、通知
- 执行 `git push`（尤其是 `--force`）或修改已推送的 Git 历史
- 执行 `rm -rf` 或任何批量删除
- 执行 `git reset --hard`
- 写入 `~/.claude/settings.json`（必须经过部署脚本干跑确认）
- 安装全局 npm 包或 Python 包（必须先报告，经确认后执行）

---

## Domain Glossary

核心词汇（避免歧义）：

| 词汇 | 含义 |
|------|------|
| Claude_up | 本 Claude Code 环境治理工具包 |
| Codex_up | OpenAI Codex 环境治理工具包（方法论参考源） |
| Phase | Claude_up 建设阶段（0=调研，1=基线，2=Skills...） |
| Skill | SKILL.md 为核心的原子能力包，跨工具通用 |
| Hook | Claude Code 确定性执行脚本，无例外 |
| MCP | Model Context Protocol，工具扩展协议 |
| ROA | Research Object Archive，研究档案格式 |
| DESIGN.md | 视觉设计规范文档（色彩/字体/间距/组件），供 AI design/coding agents 读取；与 CLAUDE.md 分工：CLAUDE.md 管"怎么构建"，DESIGN.md 管"看起来怎样" |
| 干跑 / dry-run | 只输出预览报告，不执行实际写入 |
| 双场景 | 工程开发模式（Dev）+ 个人数字助理模式（Assistant）|

---

---

## Reference

- [claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts) — Claude Code 官方系统提示词提取，10k⭐，随版本持续更新。Communication Style 和 CLAUDE.md 创建规范均参考此源。

---

*本文件部署自 `D:\MoonzWorkspace\Claude_up\01-global-config\windows-claude\CLAUDE.md`*
*安全：不含任何 API Key、Token、密码或其他敏感信息*
