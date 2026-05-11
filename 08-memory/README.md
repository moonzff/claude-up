# Claude 记忆层 · 08-memory
> 架构灵感：[Letta](https://github.com/letta-ai/letta) 记忆块系统 | 实现：纯文件，零额外依赖

## 三层架构（对照 Letta）

```
08-memory/
├── core/                    ← Core Memory（永远在上下文，字符限制）
│   ├── persona.md          [≤500 chars] Claude 角色与原则
│   ├── human.md            [≤800 chars] 用户画像（Moonz）
│   ├── projects.md         [≤1000 chars] 活跃项目快照
│   └── stack.md            [≤600 chars] 技术栈与环境
├── working/                 ← Working Memory（项目级，按需加载）
│   ├── claude-up.md        Claude_up 详细上下文
│   ├── gangan-membership.md 杆杆响会员服务
│   └── quant-trading.md    quant-trading-system
└── archive/                 ← Archival Memory（追加日志，Grep 搜索）
    ├── decisions.md        技术决策记录（append-only）
    ├── lessons.md          经验教训记录（append-only）
    └── events.md           项目里程碑记录（append-only）
```

## Letta 概念映射

| Letta 原生 | 本系统等价 | 机制 |
|-----------|---------|------|
| core_memory_append | Edit 工具追加到 core/ 文件 | 文件写入 |
| core_memory_replace | Edit 工具精准替换 core/ 内容 | 文件写入 |
| archival_memory_insert | 追加一行到 archive/ 文件 | 文件写入 |
| archival_memory_search | Grep 搜索 archive/ 目录 | 文件搜索 |
| 字符限制（block.limit） | 文件头 LIMIT 注释约束 | 人工约束 |
| 持久化（SQLite） | 文件系统（D:\MoonzWorkspace） | Git 可版本控制 |

## 与原版 Letta 的差异

| 能力 | Letta | 本系统 |
|------|-------|-------|
| 跨会话持久化 | ✅ 数据库自动 | ✅ 文件系统（等效） |
| 自编辑记忆 | ✅ 内置工具 | ✅ Claude Edit 工具 |
| 字符限制执行 | ✅ 自动截断 | ⚠️ 协议约束（靠 SKILL.md） |
| 向量搜索 archival | ✅ 语义搜索 | ⚠️ Grep 关键词搜索 |
| 多 Agent 共享块 | ✅ 数据库共享 | ✅ 文件共享（同一路径） |
| 版本历史 | ✅ BlockHistory 表 | ✅ Git 历史 |

覆盖了 Letta ~85% 的实用价值，无需安装任何额外服务。

## 完整操作协议

见：`D:\MoonzWorkspace\Claude_up\02-skills\assistant\memory-update\SKILL.md`
