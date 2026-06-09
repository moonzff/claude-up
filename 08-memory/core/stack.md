<!-- BLOCK: stack | LIMIT: 600 chars | read_only: false | updated: 2026-06-08 -->
OS: macOS (Apple Silicon) · Shell: zsh · 包管理: Homebrew (/opt/homebrew)
Node: lts(mise) · Python: 系统3.9 + uv管理3.12 · Git/gh/rsync/uv/jq 已装
Claude Code CLI: 2.1.x · Claude Desktop: 运行中
MCP(注册在~/.claude.json,非settings.json)：fs✅ playwright✅ context7✅ feishu✅ cognee✅(launchd API server并发架构,Claude/Codex/Desktop共享) github⏸(待TOKEN) codegraph⏸ letta🚫
关键路径：
  ~/.claude/ → 部署目标（settings.json + CLAUDE.md + hooks/）
  ~/MoonzWorkspace/Claude_up/ → 源码与记忆层(08-memory)
  ~/MoonzWorkspace/Claude_up/09-cognee/.venv/ → cognee 隔离环境
记忆机制：SessionStart hook 自动注入 core 四块(~/.claude/hooks/inject-memory.sh)
<!-- /BLOCK -->
