# Hooks 模板库

## 核心概念

Hooks 是 Claude Code 的**确定性执行机制**，与 CLAUDE.md 的"建议性原则"有根本区别：

- CLAUDE.md：Claude 可能遵循，也可能不遵循
- Hooks：每次都执行，无例外，无论 Claude 怎么想

## 目录结构

```
04-hooks/
├── dev/
│   ├── pre-bash-audit.json       # Bash 执行前写审计日志
│   ├── post-write-format.json    # 写文件后自动格式化
│   └── post-test-trigger.json   # 写测试文件后自动运行测试
│
└── assistant/
    ├── stop-session-summary.json # 对话结束后写会话摘要
    └── post-write-research.json  # 写入时自动归档研究对象
```

## Hook 配置结构（写入 settings.json）

```json
"hooks": {
  "PreToolUse": [{
    "matcher": "Bash",
    "hooks": [{
      "type": "command",
      "command": "echo \"[AUDIT] $(date): $CLAUDE_TOOL_INPUT_COMMAND\" >> %USERPROFILE%\\.claude\\audit.log"
    }]
  }],
  "PostToolUse": [{
    "matcher": "Write|Edit",
    "hooks": [{
      "type": "command",
      "command": "..."
    }]
  }],
  "Stop": [{
    "hooks": [{
      "type": "command",
      "command": "..."
    }]
  }]
}
```

## 环境变量

Hook 脚本中可用的 Claude Code 注入变量：

| 变量 | 含义 |
|------|------|
| `$CLAUDE_TOOL_NAME` | 当前工具名称 |
| `$CLAUDE_TOOL_INPUT_COMMAND` | Bash 命令内容 |
| `$CLAUDE_TOOL_INPUT_FILE_PATH` | 写入/读取的文件路径 |
| `$CLAUDE_SESSION_ID` | 当前会话 ID |

## 建设状态

| Hook | 事件 | 场景 | 状态 |
|------|------|------|------|
| `pre-bash-audit` | PreToolUse(Bash) | 开发 | ⏳ Phase 3 |
| `post-write-format` | PostToolUse(Write\|Edit) | 开发 | ⏳ Phase 3 |
| `stop-session-summary` | Stop | 两者 | ⏳ Phase 3 |
| `post-write-research` | PostToolUse(Write) | 助理 | ⏳ Phase 3 |
