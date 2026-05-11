# Token 效率指南

> 来源：SuperClaude Framework v4.3.0 + ccusage 实测数据
> 更新：2026-05-11

---

## 背景

ccusage 实测数据（2026-05-07 至 05-11）：
- 总花费 $747.51 / 5天 ≈ $150/天
- Output 占比异常高（2.4M output vs 50k input）
- Cache 命中率良好（57:1），但仍有大量可优化空间

---

## 核心策略

### 1. 置信度先检查（Confidence-First）

**来源**：SuperClaude ConfidenceChecker 模式

在开始任何非平凡任务前，先自我评估置信度：

| 置信度 | 含义 | 行动 |
|--------|------|------|
| ≥ 90% | 完全清楚如何做 | 直接执行 |
| 70–89% | 有不确定点 | 提出 2-3 个备选方案，用户确认后执行 |
| < 70% | 前提假设未验证 | 先问问题，不开始执行 |

**ROI**：花 100-200 token 做置信度检查，可避免 5,000–50,000 token 的方向错误。

---

### 2. Token 预算分级（Complexity Budget）

**来源**：SuperClaude token_budget 模式

按任务复杂度设定输出规模预期：

| 任务类型 | 示例 | 输出预算 |
|---------|------|---------|
| **简单**（简单修改） | 修 typo、改变量名、小 bug | ~200 tokens |
| **中等**（功能修复） | bug fix、API 调整、配置更新 | ~1,000 tokens |
| **复杂**（新功能） | 新模块、架构变更、多文件改动 | ~2,500 tokens |
| **超复杂**（系统级） | 多阶段重构、全新功能、Research 归档 | 按需，但要有意识 |

**实践**：任务开始前，在脑中预估这个任务属于哪个级别，控制自己的输出规模。

---

### 3. 并行优先执行（Wave-Checkpoint-Wave）

**来源**：SuperClaude Parallel Execution 模式

```
[读取文件 A, B, C 并行]
         ↓
    分析综合（串行）
         ↓
[写入文件 X, Y, Z 并行]
```

**适用场景**：
- 读多个无依赖文件（同时读，不是逐个读）
- 独立模块同时修改
- 多个无依赖研究任务并发

**不适用**：有严格依赖顺序的任务（A 的输出是 B 的输入）

---

### 4. 避免高 Token 浪费模式

基于实测数据识别的高成本模式：

| 浪费模式 | 原因 | 改进方式 |
|---------|------|---------|
| 大量重复内容输出 | 每轮输出完整文件 | 只输出 diff，用 Edit 工具而非 Write |
| 过长的思考过程描述 | 把内心思考写进回答 | Communication Style 原则：不叙述内部推理 |
| 不必要的代码注释 | 默认不写注释 | CLAUDE.md 已明确：代码中默认不写注释 |
| 冗余确认 | 每步都问"确认执行？" | 明确授权范围，批量授权后连续执行 |
| 错误方向长时间执行 | 置信度不足就开始 | 先做置信度检查 |

---

### 5. 缓存命中优化

当前 Cache Read/Write 比 = 57:1（优秀）。维持这个比率的关键：

- **保持系统提示词稳定**：CLAUDE.md 不频繁大改，让缓存持续有效
- **长会话优于短会话**：同一会话内缓存持续积累
- **重复使用相同的 Skill 文件**：每次读同一路径的 SKILL.md，缓存命中

---

## 与 ccusage 结合使用

定期运行检查，关注趋势：

```powershell
npx ccusage daily     # 每日成本
npx ccusage session   # 按会话分析
npx ccusage --window 5h  # 5小时计费窗口（控制 rate limit）
```

高成本会话通常意味着：方向反复、长文件全量输出、不必要的多轮确认。

---

## 参考

- [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) — PM Agent 置信度模式
- [ccusage](https://github.com/ryoppippi/ccusage) — Token 用量追踪
- `tooling/ccusage.md` — ccusage 安装与使用指南
