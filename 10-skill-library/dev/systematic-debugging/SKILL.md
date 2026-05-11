# Skill: systematic-debugging
> 来源：jnMetaCode/superpowers-zh 方法论 · 适配：Node.js / TypeScript / AWS · 版本：v1.0

## 定位

系统化调试法——四阶段结构化排查，杜绝"凭感觉乱改"。
当 `diagnose` Skill 的检查清单不够用时（问题模糊、复现不稳定、多层组件交互），切换到本 Skill。

**与 `diagnose` 的关系**：
- `diagnose`：已有明确症状，按清单快速排查
- `systematic-debugging`：症状模糊或诡异，需要科学推理

---

## 四阶段调试流程

### Phase 1 · 定位（Locate）
**目标**：把问题从"感觉哪里有问题"收窄到"具体是哪个组件/层"

```
□ 写下问题的精确描述：什么输入 → 什么错误/异常行为
□ 确定问题边界：最后一个正常状态是什么？最早出错时间/版本？
□ 复现问题：能稳定复现吗？概率？特定条件？
□ 画出数据流路径：请求从哪里进来 → 经过哪些层 → 在哪里出错
□ 缩小范围：二分法定位（哪一半有问题？再对半切）
```

**输出**：一句话定位结论，例如："问题出在 Order Service 调用 Payment API 的超时处理逻辑"

---

### Phase 2 · 分析（Analyze）
**目标**：在定位范围内收集证据，建立完整的事实基础

```
□ 查日志：时间戳、错误码、堆栈（生产日志 / CloudWatch）
□ 查状态：相关数据的当前状态是否符合预期？（DB 记录、缓存值、队列状态）
□ 查依赖：外部服务/API 是否正常？（健康检查、响应时间）
□ 查时序：并发场景下的事件顺序是否有竞态？
□ 隔离变量：只改一个条件，其他保持不变，观察结果
```

**禁止**：在 Phase 2 未完成前开始改代码。没有证据的修改是猜测，不是调试。

---

### Phase 3 · 假设（Hypothesize）
**目标**：基于证据提出可被证伪的假设，排序后逐一验证

假设格式：
```
假设 N：<原因> 导致 <现象>
验证方式：<具体怎么验证，不改代码，只观测>
预期结果：如果假设正确，应该看到 <X>
```

**排序原则**（优先验证）：
1. 最简单能验证的假设
2. 历史上出过类似 Bug 的模式
3. 最近有变更的代码路径

验证每个假设后，标注：`✅ 确认` / `❌ 排除` / `⚠️ 部分符合，需要细化`

---

### Phase 4 · 修复（Fix）
**目标**：针对已确认的根因实施最小改动

```
□ 修复根因，不是症状（治标 vs 治本）
□ 写测试先复现 Bug，再修复（TDD 修复法）
□ 修复范围：只改与根因直接相关的代码
□ 考虑同类 Bug：同一模式在其他地方还存在吗？
□ 验证修复：在复现环境中确认问题消失
□ 回归验证：相关功能的测试仍然通过
```

修复完成后执行 **verification-before-completion** Skill（如已加载）。

---

## Node.js / AWS 常见调试工具箱

```bash
# 本地日志分析
node --inspect server.js              # Chrome DevTools 调试
DEBUG=* node server.js               # 启用全量 debug 日志

# AWS CloudWatch
aws logs tail /aws/lambda/function-name --follow
aws logs filter-log-events --log-group-name /app/prod --filter-pattern "ERROR"

# 性能分析
node --prof server.js                # 生成 V8 profile
node --prof-process isolate-*.log    # 分析结果

# 数据库
# 在查询前后打 console.time/timeEnd
# 检查 explain() / EXPLAIN ANALYZE
```

---

## 调试记录模板

遇到复杂 Bug 时，在对话中维护一份记录：

```
【Bug 调试记录】
症状：
复现步骤：
定位结论（Phase 1）：
关键证据（Phase 2）：
- 
假设列表（Phase 3）：
- [ ] 假设1：
- [ ] 假设2：
根因确认：
修复方案：
验证结果：
```

---

## 原则

- **证据先于假设**：没有 Phase 2 的数据，不开始 Phase 3 的猜测
- **一次一个变量**：同时改多处等于没有调试，只是碰运气
- **记录负面结果**：排除掉的假设同样有价值，防止下次重复走弯路
- **根因而非症状**：修掉错误提示但没修掉错误逻辑，不算修复
