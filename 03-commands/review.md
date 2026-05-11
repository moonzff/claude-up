---
name: review
description: 启动六维度代码审查，覆盖正确性、安全、性能、可维护性、测试、架构
---

# /review — 代码审查命令

触发 `code-review` Skill，执行六维度系统性代码审查。

## 使用方式

```
/review [文件路径或 PR 描述]
```

## 执行流程

读取 `D:\MoonzWorkspace\Claude_up\10-skill-library\dev\code-review\SKILL.md`，按六个维度审查：

| 维度 | 检查重点 |
|------|---------|
| 正确性 | 逻辑错误、边界条件、空值处理 |
| 安全性 | 注入攻击、认证漏洞、敏感数据泄露 |
| 性能 | N+1 查询、不必要计算、内存泄漏 |
| 可维护性 | 命名清晰、职责单一、重复代码 |
| 测试覆盖 | 测试存在、边界用例、Mock 合理性 |
| 架构一致性 | 层级违反、依赖方向、接口设计 |

## 输出格式

每个问题标注：`[CRITICAL]` / `[MAJOR]` / `[MINOR]` / `[SUGGESTION]`
