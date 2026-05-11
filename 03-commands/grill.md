---
name: grill
description: 编码前需求审问，暴露隐藏假设，生成结晶化需求和实施计划
---

# /grill — 需求审问命令

触发 `grill-plan` Skill v2（Ouroboros 演化循环），在写代码前彻底厘清需求。

## 使用方式

```
/grill [任务描述]
```

## 执行流程

读取 `D:\MoonzWorkspace\Claude_up\02-skills\dev\grill-plan\SKILL.md`，执行四阶段循环：

1. **Interview**：提问暴露假设，计算歧义分数（0.0–1.0）
2. **Seed**：结晶化需求，输出 Seed 格式
3. **Execute**：生成实施计划（表格 + 风险矩阵）
4. **Evaluate**：评估循环，歧义 > 0.2 时重新循环

## 触发场景

- 新功能开发前
- 需求描述模糊时
- 跨系统集成前
- 重构前评估影响范围
