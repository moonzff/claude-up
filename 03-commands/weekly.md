---
name: weekly
description: 启动每周复盘，生成本周工作总结、认知沉淀和下周计划
---

# /weekly — 周复盘命令

触发 `weekly-review` Skill，执行结构化周复盘。

## 使用方式

```
/weekly
```

## 执行流程

1. 读取 `D:\MoonzWorkspace\Claude_up\02-skills\assistant\weekly-review\SKILL.md`
2. 引导用户回顾本周：
   - 完成了什么（项目进展）
   - 遇到了什么问题
   - 学到了什么
   - 下周计划
3. 输出结构化周报，可存入 `08-memory/archive/events.md`

## 输出格式

```markdown
# 周复盘 — YYYY-WW

## 本周完成
## 问题与卡点
## 认知沉淀
## 下周计划
```
