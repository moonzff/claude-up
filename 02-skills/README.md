# Skills 库

## 目录结构

```
02-skills/
├── dev/                          # 工程开发场景 Skills
│   ├── diagnose/                 # 系统化排障
│   ├── tdd/                      # 测试驱动开发
│   ├── grill-plan/               # 实现前审问需求
│   ├── pr-review/                # 代码审查标准化
│   ├── security-audit/           # 安全审计
│   └── dual-environment-workflow/ # Windows/WSL2 双环境工作流
│
└── assistant/                    # 个人助理场景 Skills
    ├── research-object-archive/  # 研究档案归档（ROA 格式）
    ├── summarize-meeting/        # 会议纪要提炼
    ├── daily-brief/              # 日报生成
    ├── weekly-review/            # 周报/回顾
    ├── decision-log/             # 决策记录
    └── create-prd/               # PRD 生成
```

## Skill 设计原则

1. **一个 Skill = 一个原子工程动作**（Matt Pocock 原则）
2. **SKILL.md < 100 行**：超长会降低触发精度
3. **每个 Skill 有明确的触发条件**：description 字段决定自动触发时机
4. **Scripts 可选**：复杂 Skill 可携带辅助脚本，简单 Skill 只需 SKILL.md
5. **跨工具兼容**：Skills 开放标准，与 Claude Code / Cursor / Gemini CLI 通用

## SKILL.md 模板

```yaml
---
name: skill-name
description: 一句话描述（中英文均可，决定何时被触发）
---

# Skill Name

## 触发条件
当用户...时，自动激活本 Skill。

## 执行流程
1. 第一步
2. 第二步
3. 第三步

## 输出格式
...

## 注意事项
...
```

## 建设状态

| Skill | 场景 | 状态 |
|-------|------|------|
| `diagnose` | 开发 | ⏳ Phase 2 |
| `tdd` | 开发 | ⏳ Phase 2 |
| `grill-plan` | 开发 | ⏳ Phase 2 |
| `pr-review` | 开发 | ⏳ Phase 2 |
| `dual-environment-workflow` | 开发 | ⏳ Phase 2 |
| `research-object-archive` | 助理 | ⏳ Phase 2 |
| `summarize-meeting` | 助理 | ⏳ Phase 2 |
| `weekly-review` | 助理 | ⏳ Phase 2 |
