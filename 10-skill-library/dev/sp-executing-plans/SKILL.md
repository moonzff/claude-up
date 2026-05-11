# Skill: sp-executing-plans
> 来源：obra/superpowers · 适配：Moonz 开发场景 · 版本：v1.0
> ⚠️ 子 Agent 并行执行需要 Claude Code CLI；在 Cowork 中使用顺序执行模式

## 定位

按计划文件逐任务执行，每个任务完成后做两阶段 Review，保证质量。

**前置条件**：已有计划文件（来自 sp-writing-plans）

---

## 执行模式

### 模式 A · 顺序执行（Cowork 中使用）

逐 Task 顺序执行，每个 Task 完成后立即做两阶段 Review，再进入下一个。

```
Task 1 → Review → Task 2 → Review → ... → 全部完成
```

### 模式 B · 子 Agent 并行执行（Claude Code CLI 中使用）

每个 Task 分发给独立子 Agent，子 Agent 拥有精确裁剪的上下文（不继承主会话历史）。

```
Controller 读取计划
  ├── SubAgent 1 ← Task 1 + 精确上下文
  ├── SubAgent 2 ← Task 2 + 精确上下文（如果无依赖）
  └── SubAgent 3 ← Task 3 + 精确上下文（如果无依赖）
每个 SubAgent 完成后 → 两阶段 Review → 合并
```

**子 Agent 上下文包含**：任务描述、相关文件路径、验证步骤、禁止事项（不要做 X）

---

## 两阶段 Review（每个 Task 必须经过）

### Stage 1 · Spec Compliance Review（规格符合性）

作为一个**怀疑论者**，核查实现是否与 Spec/计划完全匹配：
```
□ 每个要求的功能都实现了吗？
□ 有没有多做了 Spec 没有要求的东西？（过度实现）
□ 文件路径与计划一致吗？
□ 不读实现者的说明，直接读代码验证
```
只有 Stage 1 通过，才进入 Stage 2。

### Stage 2 · Code Quality Review（代码质量）

```
□ 代码风格与项目一致（命名、缩进、注释）
□ 没有明显的性能问题（N+1、不必要的循环）
□ 错误处理是否完备
□ 测试是否合理覆盖核心逻辑
□ 没有硬编码的魔法值、密钥
```

---

## 执行纪律

- **不跳过 Review**：即使是简单 Task 也要两阶段检查
- **遇到阻塞立即报告**：不要尝试绕过设计约束，停下来沟通
- **每 Task 一个 commit**：完成 + Review 通过即提交，不攒到最后
- **不修改计划**：执行中发现计划有问题，暂停并告知用户，而不是悄悄改
- **失败快速暴露**：发现问题越早越好，不要等到最后才发现整体方向错了

---

## 完成标准

```
□ 计划中所有 Task checkbox 已勾选
□ 每个 Task 均通过两阶段 Review
□ 所有测试通过
□ 提交历史清晰（每 Task 一个语义化 commit）
□ 更新 memory-update（working memory 记录完成情况）
```
