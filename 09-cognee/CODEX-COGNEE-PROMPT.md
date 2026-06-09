# 给 Codex 的 cognee 接入提示词

> 用途：粘贴到一个 Codex 会话，让 Codex 验证并开始使用与 Claude 共享的 cognee 语义记忆。
> 前提：cognee MCP 已在 `~/.codex/config.toml` 注册（经 `09-cognee/cognee-mcp-wrapper.sh` 加 `--api-url` 连到常驻 API server）。

---

你已接入一个**跨工具共享的语义记忆系统 cognee**——和 Moonz 在 Claude Code 里用的是**同一个知识图谱**。请帮我验证并开始使用它。

## 架构（你需要知道的）
- 有一个常驻 cognee FastAPI server（launchd 服务 `com.moonz.cognee-api`，绑 `127.0.0.1:8000`）**独占**文件数据库（`~/MoonzWorkspace/Claude_up/09-cognee/.data_storage` + `.cognee_system`）。
- 你的 cognee MCP 是连到这个 server 的 **HTTP 瘦客户端**（wrapper 带 `--api-url`）——所以你和 Claude/Desktop 可以**并发**访问同一份记忆，不会撞单写锁。
- 图谱里有 Moonz 的项目、技术决策、经验教训（来自 `08-memory` 四层记忆）。

## 请按顺序验证
1. 确认你有 cognee 的 MCP 工具（`recall` / `search` / `remember` / `cognify` 等）。
2. 调 `search`（或 `recall`）查询「**Moonz 当前在跑哪些项目？**」，应返回 quant-arena / ganganxiangPM / Claude_up / GameStudio-Pilot——证明你读到了共享记忆。
3. 再查一条验证深度：「**cognee 接 DashScope 有哪些配置坑？**」或「**Claude Code 的 MCP server 应注册在哪个文件？**」（正确答案：`~/.claude.json`，不是 settings.json）。

## 使用约定（之后每次会话）
- **会话开始**：先 `recall` 当前任务/项目相关记忆，建立上下文，不要让 Moonz 重复介绍背景。
- **产生重要决策 / 踩坑教训 / 稳定结论**：用 `remember` 存进去（会和 Claude 共享）。但**未经要求不要大量主动写入**（共享图谱，避免噪声）。
- **文件层记忆**在 `~/MoonzWorkspace/Claude_up/08-memory/`：core 四块（角色/用户/项目/技术栈）· working/（项目详情）· semantic/（规律约定）· archive/（决策/教训/事件）。需要结构化基础上下文时读这些。
- 写记忆纪律见 `~/MoonzWorkspace/Claude_up/02-skills/assistant/memory-update/SKILL.md`。

## 连不上时的排查
- 终端跑 `launchctl list | grep cognee`（应有 `com.moonz.cognee-api`）+ `curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8000/docs`（应 200）。
- server 没起 → `launchctl load -w ~/Library/LaunchAgents/com.moonz.cognee-api.plist`。server 没起时所有 cognee 客户端都连不上 8000。
- 想长期固化「会话开始先 recall」的行为，把上面「使用约定」写进 Codex 的 `~/.codex/AGENTS.md`。
