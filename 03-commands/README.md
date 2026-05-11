# 03-commands — 斜杠命令目录

全局斜杠命令（Slash Commands），部署后在任意 Claude Code 会话中通过 `/命令名` 触发。

## 命令列表

| 命令 | 触发 Skill | 适用场景 |
|------|-----------|---------|
| `/research` | research-object-archive | 调研对象结构化归档 |
| `/weekly` | weekly-review | 每周复盘与认知沉淀 |
| `/grill` | grill-plan v2 | 编码前需求审问 |
| `/diagnose` | diagnose | 系统化排障 |
| `/review` | code-review | 六维度代码审查 |

## 部署方式

命令文件需部署到 `~/.claude/commands/` 才能生效。
通过 `06-deployment-kit/install_claude_app.ps1` 自动部署，或手动复制：

```powershell
Copy-Item "D:\MoonzWorkspace\Claude_up\03-commands\*.md" -Destination "$env:USERPROFILE\.claude\commands\" -Force
```

## 与 Skills 的关系

斜杠命令 = Skill 的快速入口。命令文件保持轻量（只引用路径），实际逻辑在 SKILL.md 中维护，避免重复。

## 注意

- 命令文件修改后需重新部署才能生效
- 命令名区分大小写（建议全小写）
- 与 `02-skills/` 的 Skill 相比，命令更适合"一句话触发"的高频操作
