---
name: diagnose
description: 启动系统化排障流程，5步结构化定位并修复问题
---

# /diagnose — 排障命令

触发 `diagnose` Skill，执行结构化故障定位。

## 使用方式

```
/diagnose [问题描述]
```

## 执行流程

读取 `D:\MoonzWorkspace\Claude_up\02-skills\dev\diagnose\SKILL.md`，执行 5 步排障：

1. **症状收集**：描述问题现象，收集错误日志
2. **范围定位**：确定问题边界（前端/后端/网络/配置）
3. **假设生成**：列出可能原因，按概率排序
4. **验证优先**：从最高概率假设开始验证
5. **修复确认**：修复后验证问题消失，无副作用

## 适用场景

- Build 失败
- 运行时错误
- 性能问题
- 配置错误
- 环境问题（WSL2/Windows 路径）
