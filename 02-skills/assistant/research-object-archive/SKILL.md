---
name: research-object-archive
description: Archive a research subject into a structured Research Object Archive (ROA) file. Trigger when user says "archive this research", "save research on X", "create a research note for Y", or after finishing a research session.
---

# Research Object Archive (ROA)

将一次调研结果固化为高密度、可复用的研究档案。一个档案 = 一个研究对象的完整认知压缩。

## 触发条件

用户说"归档这次调研"、"保存关于 X 的研究"、"整理成研究档案"，或完成一次调研会话后。

## 执行流程

### 1. 信息收集（如果上下文不完整，先问以下问题）

- 研究对象是什么（名称、URL、版本）？
- 核心问题是什么（为什么要研究它）？
- 来源类型：官方文档 / 社区案例 / 原始代码 / 论文 / 其他？

### 2. 生成档案文件

按以下模板输出，然后写入 `D:\MoonzWorkspace\Claude_up\08-research\` 或用户指定路径。

文件命名规则：`YYYYMMDD_research_<对象名称-kebab-case>.md`

### 3. 写入文件

确认路径后，使用 Write 工具写入文件。

---

## 档案模板

```markdown
# [对象名称] Research

## Metadata
- 来源：[URL 或本地路径]
- 日期：[YYYY-MM-DD]
- 状态：[draft / reviewed / archived]
- 标签：[关键词，逗号分隔]

## Research Question
[为什么要研究这个对象？一到两句话明确问题。]

## Bottom Line
[一段话（3-5 句）压缩核心结论。这是最重要的部分，未来回顾时优先读这里。]

## What To Borrow

| 模式 / 机制 | 价值 | 适配方式 | 置信度 |
|------------|------|---------|--------|
| [具体可借鉴的做法] | [为什么有价值] | [如何移植到当前项目] | 高/中/低 |

## Evidence

| 来源 | 类型 | 关键发现 | 链接/路径 |
|------|------|---------|----------|
| [文档名/URL] | 官方文档/代码/案例 | [发现内容摘要] | [链接] |

## Applicability

**适用场景：**
- [场景 1]
- [场景 2]

**不适用场景：**
- [场景 1]

**前提条件：**
- [必须满足的条件]

## Risks And Limits

| 风险类型 | 具体风险 | 缓解方式 |
|---------|---------|---------|
| 技术风险 | | |
| 兼容性风险 | | |
| 维护风险 | | |
| 信息时效风险 | | |

## Comparison Notes
[与其他已研究对象的横向比较，1-3 条关键差异。]

## Follow-Up

- [ ] [待确认的问题或下一步行动]
- [ ] [可能演化为 Skill 的候选]
```

---

## 注意事项

- Bottom Line 是核心，宁可删减其他部分也要保证这里信息密度足够
- What To Borrow 表格每行必须有明确的"适配方式"，不能只写"可参考"
- 文件写入后在当前会话中告知路径
- 不在档案中写入任何 API Key、Token 或密码
