# 记忆系统落地 — 会话交接（HANDOFF）

> 日期：2026-06-08 | 上个会话因过长导致工具调用不稳，开新会话接力。
> 计划全文：`~/.claude/plans/swirling-booping-brooks.md`

> **续会话进展（2026-06-08 第二次接力，本次完成）**：
> - **B3 冒烟+灌库 ✅**：定位并修复 cognee 3 大配置根因（litellm 缺 `openai/` 前缀致连接超时 / embedding 该用 `openai_compatible` 绕 tiktoken / 维度 1024 + batch≤10 适配 DashScope，详见 lessons **L022**+排障 **L023**）。13 个规范文件灌入知识图谱（19MB，0 错误），3 条召回验证精准。
> - **settings.json 修正 5 处 ✅**（已 diff 预览 + 用户确认 + 备份）：LLM_MODEL 加前缀 / EMBEDDING_PROVIDER→openai_compatible / +EMBEDDING_DIMENSIONS=1024 / +EMBEDDING_BATCH_SIZE=10 / +ENABLE_BACKEND_ACCESS_CONTROL=false。
> - **MCP 握手验证 ✅**：用该配置启动 cognee-mcp，12 工具就绪、无报错（B4 极可能直接 Connected）。
> - **Part C 文档 ✅**：mac-claude/CLAUDE.md 记忆章节（hook 接管 + 工具名 `mcp__cognee__recall`/`remember` 校正）· settings.json profile 同步 · archive decisions(+6)/events(+1)/lessons(L022/L023)。
> - **剩余**：B4（用户重启 Desktop + `claude mcp list` 验证 Connected）· git commit（待用户明确授权，未提交）。

## 总目标
两手抓修复 Claude 记忆：
1. **机制保底**：SessionStart hook 把 core 四块确定性注入每个会话（零依赖）。
2. **语义加速**：cognee 1.1（venv 隔离 + DashScope 后端）。
3. 自动化范围：只自动“读”，写入保持半自动。

## 已完成 ✅
- **hook 脚本**：`~/.claude/hooks/inject-memory.sh` 已建+chmod，实测输出合法 JSON、注入 core 四块、3359 字符、0 Windows 残留。
- **core 四块已更新为 Mac**：persona/human/projects/stack（08-memory/core/）全部从 Windows 改为 macOS + 最新项目状态。
- **DASHSCOPE key**：已设入 `~/.zshrc`（CLI）+ `launchctl setenv`（GUI）；实测 DashScope embedding HTTP 200、1024 维，key 有效（sk-ecf… len35）。
- **cognee 装好**：`~/MoonzWorkspace/Claude_up/09-cognee/.venv`（uv 建 3.12）装了 cognee 1.1.2 + cognee-mcp 0.5.4（含 torch）。
- **settings.json 改好**（`~/.claude/settings.json`，已备份 settings.json.bak-before-memory-*）：
  - cognee.command → `…/09-cognee/.venv/bin/cognee-mcp`，args `["--transport","stdio"]`
  - 末尾加 SessionStart hook（matcher: startup|resume|clear）
  - env：DATA_ROOT_DIRECTORY + SYSTEM_ROOT_DIRECTORY 指向 09-cognee/（替换了无效的 COGNEE_DATA_PATH）
  - LLM/EMBEDDING key 仍用 `${env:DASHSCOPE_API_KEY}` 占位符（不硬编码）
- **关键坑已查实**：
  - cognee 1.1 的 MCP 入口是独立命令 `cognee-mcp`，不是 `python -m cognee.mcp`（旧配置已失效，已修）。
  - 数据目录控制变量是 `DATA_ROOT_DIRECTORY`/`SYSTEM_ROOT_DIRECTORY`（pydantic 字段大写），`COGNEE_DATA_PATH` 无效（已修）。

## 待完成 ⏳
- **B3 cognee 冒烟+灌库**：跑 add→cognify→search 确认端到端通（上个会话 search 只到“Searching for…”没看到实质答案，需复测）；通了再把 08-memory 17 个 md 灌入。
  - 现成脚本骨架见下方“附：冒烟脚本”。注意 grep 过滤别太狠以免吞掉答案。
- **A3 验证 hook 注入**：开新会话本身即验证——若新会话一开始就“知道 Moonz 是谁/在 macOS/有哪些项目”，说明 hook 生效。
- **B4 cognee MCP 连接**：重启 Claude Desktop → `claude mcp list` 看 cognee 是否 ✓ Connected（GUI 走 launchctl 的 key）。
- **C 收尾**：更新 mac-claude/CLAUDE.md 记忆章节（注明 hook 已接管 + cognee venv 路径 + 正确 env 变量）；同步 settings.json profile；追加 08-memory/archive/decisions.md+events.md；提交 Claude_up（commit 确认、push 确认）。

## 重要约束
- 写 ~/.claude/settings.json 前必须 Read+diff 预览+用户确认（用户红线）。
- 装包/改 .zshrc/launchctl 需用户确认。
- 不 commit / 不 push 除非用户明确说。
- cognee 命令带 Python 代码时**写成脚本文件再 bash 执行**，不要在 Bash command 里塞多重引号+heredoc（会触发解析问题）。

## 附：冒烟脚本（修正 sed 转义）
环境变量见 settings.json 的 cognee.env；key 取法：
`KEY="$(grep DASHSCOPE_API_KEY ~/.zshrc | sed -E 's/.*="(.*)".*/\1/')"`
需 export：LLM_API_KEY/LLM_PROVIDER=openai/LLM_MODEL=qwen-plus/LLM_ENDPOINT、
EMBEDDING_*（同 key，model=text-embedding-v3，dim=1024，endpoint 同）、
DATA_ROOT_DIRECTORY + SYSTEM_ROOT_DIRECTORY 指向 09-cognee/。
然后 `.venv/bin/cognee-cli add "..." / cognify / search "..."`。
