# CHANGELOG

## [v1.0.0] — 2026-05-11

### Changed — Phase 12：系统提示词研究 + CLAUDE.md 优化

**研究来源**：[Piebald-AI/claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts)（10.1k⭐，随 Claude Code 版本自动更新到 v2.1.138）

**CLAUDE.md 优化（v1.0 → v1.1）**：
- `Progress Audit Requirement` 章节 → 替换为 `Communication Style` 章节（对齐官方 v2.1.104 规范）
  - 原格式：强制每轮输出 7 行结构化进度块（高 token 成本）
  - 新规范：首工具调用前一句，关键节点一句更新，轮次结束 1-2 句总结
- `Do Not Do` 精简：合并 git push + 修改历史条目，删除已在 Operating Principles 重复的密钥条目
- 新增 `Reference` 章节：记录 claude-code-system-prompts 参考源

**README 修复**：
- `README.md` + `README_ZH.md`：替换 `your-username` 占位符为 `moonzff`
- 版本 badge：v0.9.0 → v1.0.0

**公开发布**：
- GitHub 仓库：https://github.com/moonzff/claude-up（v0.9.0 已发布）
- v0.9.0 GitHub Release 已创建

---

## [v0.9.0] — 2026-05-10

### Changed — 记忆系统升级为四层架构（吸收 agentmemory 设计理念）

**架构升级**：Letta 三层 → 四层（Core / Working / **Semantic** / Archive）

**新增 Semantic 层**（`08-memory/semantic/`）：
- `patterns.md` — 规律模式库（置信度 + 强化次数 + 证据链 + 行动准则）
- `conventions.md` — 约定惯例库（编码/部署/工作流约定，带置信度）
- 初始预填：4 条规律（P001–P004）· 5 条约定（C001–C005）

**memory-update SKILL.md → v2.0**（新增 5 种操作）：
- `semantic_query` — 遇到重复决策时查询规律/约定
- `semantic_distill` — 同类教训 2+ 次时蒸馏为规律
- `memory_reinforce` — 规律被新场景验证时 reinforced+1
- `memory_evolve` — 记忆进化取代（superseded_by，不删除旧记忆）
- `contradiction_check` — 写入前矛盾检测

**格式升级**：`archive/lessons.md` 新增 LES 结构化元数据（id/confidence/reinforced/concepts）

**吸收来源**：`rohitg00/agentmemory`（290⭐）
- ✅ 已吸收：置信度评分、记忆进化、矛盾检测、4层架构、结构化压缩、规律强化
- ❌ 未引入：iii-engine 服务依赖、自动捕获 Hooks（Cowork 无法触发）、向量搜索

---

## [v0.8.1] — 2026-05-09

### Added — 10-skill-library/ 补充 2 个 Skill（来源：superpowers-zh 方法论）

- `dev/systematic-debugging/` — 四阶段调试法（定位→分析→假设→修复），补足 diagnose Skill 的盲区
- `dev/verification-before-completion/` — 证据先行原则，嵌入 sp-executing-plans 每个任务完成节点

> 调研 jnMetaCode/superpowers-zh（22⭐），14 个翻译 Skill 与现有库高度重叠，仅提取 2 个真正有增量价值的方法论，其余不引入。

---

## [v0.8.0] — 2026-05-09

### Added — 10-skill-library/ 技能库框架

**架构**：新增 `10-skill-library/` 目录，与全局 `02-skills/` 分开：
- `02-skills/`：高频通用，每次会话默认可用（≤10个）
- `10-skill-library/`：专项按需，任务时从 INDEX.md 查找并加载

**INDEX.md**：技能索引，含触发场景描述 + CLI 限制标注 + 路径

**superpowers 三件套**（来源：obra/superpowers，116k+ ⭐）：
- `dev/sp-brainstorming/` — 编码前设计澄清（接 grill-plan 使用）
- `dev/sp-writing-plans/` — 实施计划编写（2-5min/task 颗粒度）
- `dev/sp-executing-plans/` — 计划执行 + 两阶段 Review（Cowork 顺序/CLI 并行）

**核心 Dev Skills**：
- `dev/code-review/` — 六维度代码审查（正确性/安全/性能/可维护/测试/架构）
- `dev/security-audit/` — Node.js + AWS 安全审计（覆盖 OWASP Top 10）
- `dev/api-design/` — REST API 设计规范（Node.js 适配）

**CLAUDE.md 更新**：新增 Skill Library 使用协议

### Notes
- superpowers 完整开发流水线：grill-plan → sp-brainstorming → sp-writing-plans → sp-executing-plans
- sp-executing-plans 子 Agent 并行执行需要 Claude Code CLI，Cowork 用顺序模式
- 库中预留位置：db-design / aws-patterns / quant-strategy / perf-profile（待补充）

---

## [v0.7.1] — 2026-05-09

### Changed — 08-memory/ 重构为 Letta 三层架构

**架构升级**：参考 Letta 记忆块设计，将 08-memory/ 从平铺 Markdown 重构为三层结构：

- `08-memory/core/` — Core Memory（4 块，字符限制，永远加载）
  - `persona.md`（≤500）·`human.md`（≤800）·`projects.md`（≤1000）·`stack.md`（≤600）
- `08-memory/working/` — Working Memory（项目级，按需加载）
  - `claude-up.md` · `gangan-membership.md` · `quant-trading.md`
- `08-memory/archive/` — Archival Memory（追加日志，Grep 搜索）
  - `decisions.md` · `lessons.md` · `events.md`

**新增 Skill**：`02-skills/assistant/memory-update/SKILL.md`
  - 定义 6 种记忆操作（对照 Letta memory tools）
  - 会话启动协议 + 会话结束检查协议
  - 字符限制规则与压缩策略

**CLAUDE.md 更新**：记忆协议升级为三层架构版本，明确 core/working/archive 操作流程

**覆盖 Letta ~85% 实用价值**：持久化 ✅ · 自编辑 ✅ · 搜索（Grep）✅ · 版本历史（Git）✅
不支持：向量语义搜索、自动字符限制执行

---

## [v0.7.0] — 2026-05-09

### Added — Phase 7：外部智能层接入

**Phase 7-A：GitHub MCP**
- `01-global-config/windows-claude/settings.json` — 新增 `github` mcpServer（`@modelcontextprotocol/server-github`）
- `01-global-config/windows-claude/settings.json` — permissions.allow 新增 `mcp__github__*` 和 `mcp__letta__*`
- `05-mcp/github.json` — GitHub MCP 配置文档（含激活步骤、Token 设置说明）
- `01-global-config/windows-claude/CLAUDE.md` — 工具链现状 + MCP 接入状态 更新

**Phase 7-B：Letta 记忆层（双轨部署）**
- `01-global-config/windows-claude/settings.json` — 新增 `letta` mcpServer（`letta-mcp`，指向 localhost:8283）
- `05-mcp/letta.json` — Letta MCP 配置文档（含架构说明、记忆块设计、激活步骤）
- `06-deployment-kit/start-letta-server.bat` — Letta 服务启动器（含安装检测、端口检测）
- `08-memory/README.md` — 记忆层说明文档
- `08-memory/user-profile.md` — 用户档案（身份/偏好/风格）— 立即可用
- `08-memory/active-projects.md` — 活跃项目速览 — 立即可用
- `08-memory/technical-stack.md` — 技术栈与环境速查 — 立即可用
- `01-global-config/windows-claude/CLAUDE.md` — 新增"会话启动记忆协议"

### Notes
- GitHub MCP：待激活。下一步：在 Windows 环境变量中设置 `GITHUB_TOKEN`，重启 Claude
- Letta MCP：待激活。下一步：`pip install letta` + `npm install -g letta-mcp-server`，运行启动器
- 文件记忆层（08-memory/）**今天即可使用**，通过现有 filesystem MCP 访问，无需额外安装

---

## [v0.6.1] — 2026-05-08

### Changed
- `02-skills/dev/grill-plan/SKILL.md` 升级至 v2.0.0
  - 引入 Ouroboros 演化循环模式：Interview → Seed → Execute → Evaluate
  - 新增歧义分数机制（0.0–1.0），歧义 > 0.2 时强制循环
  - Phase 2 增加需求结晶（Seed）输出格式
  - Phase 4 增加评估循环和完成回顾
  - 实施步骤升级为表格格式，包含风险概率和已知未知
  - 灵感来源：Q00/ouroboros Agent OS

---

## [v0.6.0] — 2026-05-07 Release 🎉
所有 Phase 0–6 完成，Claude_up 工具包正式可用。

---

## [Phase 6] — 2026-05-07 Complete ✅

### Added
- `06-deployment-kit/install_claude_app.ps1` 升级：新增 `-Profile dev|assistant|full` 参数，支持场景化部署
- `06-deployment-kit/BOOTSTRAP.md` — 新机器从零引导文档（前置条件 + 5步清单 + 常见问题）
- `99-manifest/VERSION` — v0.6.0

---

## [Phase 5] — 2026-05-07 Complete ✅

### Added
- `cli/claude_app.ps1` — Diagnostic CLI，6 命令：doctor / mcp-check / skill-list / config-validate / memory-audit / deploy-dry-run
- `cli/run.bat` — 双击启动器

### Verified
- `doctor` 全量检查 6/6 通过：Claude Home ✓ · settings.json 同步 ✓ · 结构校验 ✓ · CLAUDE.md 142行 ✓ · 6 Skills ✓ · npx 可用 ✓

---

## [Phase 4] — 2026-05-07 Complete ✅

### Added
- `05-mcp/playwright.json` — 浏览器自动化 MCP 配置
- `05-mcp/context7.json` — 实时库文档 MCP 配置
- `05-mcp/baseline-mcp.json` 更新：playwright + context7 → status: active
- `01-global-config/windows-claude/settings.json` 更新：mcpServers 新增 playwright + context7

---

## [Phase 3] — 2026-05-07 Complete ✅

### Added
- `04-hooks/dev/pre-bash-audit.json` — PreToolUse(Bash) → audit.log
- `04-hooks/dev/post-write-format.json` — PostToolUse(Write|Edit) → prettier
- `04-hooks/assistant/stop-session-summary.json` — Stop → session-log.txt
- `04-hooks/assistant/post-write-research.json` — PostToolUse(Write on research paths) → ROA 提醒
- `01-global-config/windows-claude/settings.json` 更新：集成全部 4 个 hooks
- `06-deployment-kit/deploy_execute.bat` — 已成功部署至 `~/.claude/`

---

## [Phase 2] — 2026-05-07 Complete ✅

### Added
- `02-skills/dev/dual-environment-workflow/SKILL.md` — Windows/WSL2 路径路由规则
- `02-skills/dev/diagnose/SKILL.md` — 5步结构化调试流程
- `02-skills/dev/grill-plan/SKILL.md` — 3阶段编码前规划
- `02-skills/assistant/research-object-archive/SKILL.md` — ROA 结构化归档
- `02-skills/assistant/summarize-meeting/SKILL.md` — 会议纪要提取
- `02-skills/assistant/weekly-review/SKILL.md` — 周复盘 + 认知沉淀

---

## [Phase 1] — 2026-05-07 Complete ✅

### Added
- Root files: README.md, ROADMAP.md, SECURITY.md, .gitignore
- `01-global-config/windows-claude/settings.json` — 全局权限边界模板
- `01-global-config/windows-claude/CLAUDE.md` — 全局指令记忆模板
- `05-mcp/baseline-mcp.json` — MCP 基线配置（filesystem）
- `06-deployment-kit/install_claude_app.ps1` — 部署脚本（dry-run 默认）
- `06-deployment-kit/deploy_execute.bat` — 一键部署
- `06-deployment-kit/deploy_dryrun.bat` — 预览部署差异
- `06-deployment-kit/deployment-checklist.md` — 部署检查清单
- `99-manifest/CHANGELOG.md` — 本文件

### Deployed
- settings.json + CLAUDE.md → `C:\Users\admin\.claude\`（已验证）

---

## [Phase 0] — 2026-05-07 Complete ✅

### Research Completed
- Codex_up 全目录分析
- Research/Claude_up 10 份研究档案读取
- Claude Code 官方文档（settings.json、CLAUDE.md、Hooks、Skills）
- 社区案例：Karpathy 准则、Matt Pocock Skills、GenericAgent、awesome-claude-code

### Deliverables
- `00-overview/20260507_research_v0.1_environment-survey.md` — 环境调研报告
- `00-overview/20260507_research_v0.2_cognitive-synthesis.md` — 综合建设规划
