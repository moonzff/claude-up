# Skill Library · INDEX
> 按需加载。使用前读此文件，找到匹配 Skill，再读对应 SKILL.md 执行。
> 路径：`D:\MoonzWorkspace\Claude_up\10-skill-library\`

---

## 使用协议

遇到专项任务时：
1. 读此 INDEX，找到匹配条目
2. 读对应 SKILL.md（路径见每行末尾）
3. 按 Skill 定义的流程执行

**不需要时不要加载**——这是 skill library 的核心设计原则。

---

## Dev · 开发类

| Skill | 触发场景 | CLI限制 | 路径 |
|-------|---------|---------|------|
| **sp-brainstorming** | 开始新功能/项目前，需要澄清设计方向 | 无 | `dev/sp-brainstorming/SKILL.md` |
| **sp-writing-plans** | 设计确认后，需要写详细实施计划 | 无 | `dev/sp-writing-plans/SKILL.md` |
| **sp-executing-plans** | 有计划文件，需要并行子 Agent 执行 | ⚠️ 需要CLI | `dev/sp-executing-plans/SKILL.md` |
| **sp-tdd** | 需要测试驱动开发流程 | 无 | `dev/sp-tdd/SKILL.md` |
| **systematic-debugging** | Bug 模糊/诡异/多层交互时，四阶段系统化排查（定位→分析→假设→修复） | 无 | `dev/systematic-debugging/SKILL.md` |
| **verification-before-completion** | 声称任何任务完成前，必须先跑验证看到证据——嵌入 sp-executing-plans 使用 | 无 | `dev/verification-before-completion/SKILL.md` |
| **code-review** | 对一段代码/PR 做系统性审查 | 无 | `dev/code-review/SKILL.md` |
| **security-audit** | 对代码或系统做安全审计 | 无 | `dev/security-audit/SKILL.md` |
| **api-design** | 设计 REST API 接口（Node.js 后端） | 无 | `dev/api-design/SKILL.md` |
| **task-master** | 大项目（3+会话）跨会话任务持久化，防止执行循环和会话失忆 | ⚠️ 需要CLI | `dev/task-master/SKILL.md` |
| **db-design** | 数据库 schema 设计或查询优化 | 无 | `dev/db-design/SKILL.md` |
| **aws-patterns** | 集成 AWS 服务（S3/Lambda/RDS 等） | 无 | `dev/aws-patterns/SKILL.md` |
| **perf-profile** | 性能瓶颈分析与优化 | 无 | `dev/perf-profile/SKILL.md` |
| **quant-strategy** | 量化策略开发、回测设计 | 无 | `dev/quant-strategy/SKILL.md` |

## Assistant · 助理类

| Skill | 触发场景 | CLI限制 | 路径 |
|-------|---------|---------|------|
| **deep-research** | 需要对某主题做深度调研，输出结构化报告 | 无 | `assistant/deep-research/SKILL.md` |
| **decision-log** | 需要记录和整理一次重要决策 | 无 | `assistant/decision-log/SKILL.md` |

---

## 与全局 Skills 的关系

**全局安装**（`02-skills/`，每次会话默认可用）：
- `grill-plan` · `diagnose` · `dual-environment-workflow`（Dev）
- `research-object-archive` · `summarize-meeting` · `weekly-review` · `memory-update`（Assistant）

**Skill Library**（本目录，按需加载）：
- 专项任务技能，需要时手动激活，不占默认上下文

---

## 添加新 Skill

在对应目录创建 `SKILL.md`，并在此 INDEX 中添加一行。
格式要求：触发场景描述需清晰到"遇到 X 情况就用这个"的程度。
