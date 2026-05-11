---
name: research
description: 启动 Research Object Archive (ROA) 归档流程，将调研成果结构化存储
---

# /research — 调研归档命令

触发 `research-object-archive` Skill，对当前调研对象执行结构化归档。

## 使用方式

```
/research [调研对象名称]
```

## 执行流程

1. 读取 `D:\MoonzWorkspace\Claude_up\02-skills\assistant\research-object-archive\SKILL.md`
2. 按照 ROA 格式输出：
   - **Metadata**：来源、日期、状态
   - **Research Question**：明确问题
   - **Bottom Line**：一段话核心结论
   - **What To Borrow**：表格 — 模式 → 价值 → 适配方式 → 置信度
   - **Evidence**：来源 → 类型 → 相关发现
   - **Applicability**：适用 vs 不适用
   - **Risks And Limits**：风险说明
   - **Follow-Up**：行动项

## 存储路径

归档文件保存至 `D:\MoonzWorkspace\Research\<项目>\` 目录，文件名格式：
`YYYYMMDD_research_v0.1_<对象名>.md`
