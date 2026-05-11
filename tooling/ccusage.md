# ccusage — Claude Code 用量与成本追踪

> 仓库：[ryoppippi/ccusage](https://github.com/ryoppippi/ccusage) · 零安装，读本地 JSONL 日志

## 是什么

读取 `~/.claude/projects/` 下的本地 JSONL 日志，分析 Token 用量和成本。
无需 API Key，无需服务，纯离线运行。

## 快速开始

```bash
# 无需安装，直接运行
npx ccusage daily      # 按日统计
npx ccusage monthly    # 按月统计
npx ccusage session    # 按会话统计
npx ccusage blocks     # 按 5小时计费窗口统计（管理 rate limit 用）
```

## 常用场景

### 查看今日消耗
```bash
npx ccusage daily --since today
```

### 查看本月成本（按项目）
```bash
npx ccusage monthly
```

### Rate Limit 管理
Claude 的计费窗口是 5 小时滚动窗口，`blocks` 视图帮助判断当前窗口还剩多少额度：
```bash
npx ccusage blocks
```

### MCP 集成（可选）
如果在 Claude Code CLI 中使用，可以将 ccusage 接入 MCP：
```json
{
  "mcpServers": {
    "ccusage": {
      "command": "npx",
      "args": ["ccusage", "mcp"]
    }
  }
}
```
配置后可在对话中直接问："我今天用了多少 Token？"

## 注意

- 日志路径：Windows 下为 `%APPDATA%\Claude\` 或 `~/.claude/projects/`
- 离线模式：使用预缓存定价数据，无需网络
- Cowork 和 CLI 的日志都在同一目录下，ccusage 会统一读取
