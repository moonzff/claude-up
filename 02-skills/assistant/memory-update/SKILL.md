# Skill: memory-update
> 版本：v2.0 | 灵感：Letta 块架构 + agentmemory 设计理念 | 适用：Cowork + CLI

## 定位

Claude 的记忆管理工具集。实现跨会话知识积累——无需外部服务，纯文件实现。

v2.0 新增：置信度评分、结构化压缩、记忆进化（取代旧记忆）、矛盾检测、Semantic 层蒸馏。

记忆层路径：`D:\MoonzWorkspace\Claude_up\08-memory\`

---

## 四层记忆架构（v2.0）

| 层级 | 路径 | 类比 | 何时加载 |
|------|------|------|---------|
| **Core** | `core/` | RAM | 每次新会话自动读取，4 个块 |
| **Working** | `working/` | 工作台 | 进入具体项目时按需读取 |
| **Semantic** | `semantic/` | 知识库 | 查找规律/约定时读取 |
| **Archive** | `archive/` | 磁盘日志 | 需要历史查询时 Grep 搜索 |

### Core 块字符限制

| 块 | 文件 | LIMIT |
|----|------|-------|
| persona | `core/persona.md` | ≤500 |
| human | `core/human.md` | ≤800 |
| projects | `core/projects.md` | ≤1000 |
| stack | `core/stack.md` | ≤600 |

---

## 记忆操作

### 1. core_memory_read（会话启动）

```
依次 Read：
  core/persona.md → core/human.md → core/projects.md → core/stack.md
目标：建立完整上下文，不需要用户重复介绍背景
```

### 2. core_memory_append / replace

```
append：在 <!-- /BLOCK --> 前追加，更新 updated: 日期，检查不超限
replace：Edit 精准替换旧内容，外科手术式，只动目标行

超限处理（>90% LIMIT）：
  → core_memory_compress：把详细内容移到 working/ 对应文件，core 保留精炼摘要
```

### 3. archival_memory_insert（写入归档）

写入 archive/ 时使用 **结构化格式**（agentmemory 压缩理念）：

**lessons.md**：
```
<!-- LES | id: LNNN | confidence: 0.X | reinforced: N | date: YYYY-MM-DD | concepts: [tag1, tag2] -->
[YYYY-MM-DD] [项目/场景] 教训内容。
→ 关联规律/约定：PNNN / CNNN（如有）
<!-- /LES -->
```

**decisions.md**：
```
[YYYY-MM-DD] [项目] 决策内容 · 原因：xxx
```

**events.md**：
```
[YYYY-MM-DD] [项目] 里程碑描述
```

**confidence 标准**：
- 0.95+ = 多次验证，确定无疑
- 0.80–0.94 = 有证据，场景有限
- 0.60–0.79 = 初次观察，需要更多验证

### 4. archival_memory_search（搜索归档）

```
用 Grep 工具搜索 archive/ 或 semantic/ 目录
示例：Grep pattern="AWS" path="D:\MoonzWorkspace\Claude_up\08-memory\archive\"
```

### 5. working_memory_load / update（项目工作记忆）

```
load：进入项目时 Read 对应 working/ 文件
  Claude_up → working/claude-up.md
  杆杆响 → working/gangan-membership.md
  quant-trading → working/quant-trading.md

update：工作结束后 Edit 更新项目状态章节，更新 updated: 日期
```

### 6. semantic_query（查询规律/约定）

```
触发：遇到重复决策场景、不确定技术约定时
操作：Read semantic/patterns.md 或 semantic/conventions.md
目标：找到已有规律，避免重复踩坑
```

### 7. semantic_distill（蒸馏新规律）——v2.0 新增

```
触发：archive/ 中同类教训出现 2+ 次，或发现新的稳定规律
操作：
  1. 在 semantic/patterns.md 追加新条目（PAT 格式）
  2. 或在 semantic/conventions.md 追加新约定（CONV 格式）
  3. 在 archive/lessons.md 对应条目添加 → 关联规律：PNNN

PAT 格式：
<!-- PAT | id: PNNN | confidence: 0.X | reinforced: N | last: YYYY-MM-DD -->
## [PNNN] 规律名称
**规律**：一句话描述
**证据**：- 事件（+1）
**行动**：决策准则
<!-- /PAT -->
```

### 8. memory_reinforce（强化已有规律）——v2.0 新增

```
触发：某条 lessons 或 patterns 条目被新场景再次验证
操作：
  1. 在 semantic/patterns.md 对应 PAT 条目：reinforced +1，更新 last 日期，追加证据
  2. 在 archive/lessons.md 对应 LES 条目：reinforced +1
  原则：只追加证据，不修改历史内容
```

### 9. memory_evolve（记忆进化取代）——v2.0 新增

```
触发：某条旧记忆被新信息推翻或升级（如技术方案切换）
操作：
  1. 在旧条目末尾（<!-- /PAT --> 前）追加：
     superseded_by: PNNN | date: YYYY-MM-DD | reason: 原因
  2. 新建取代条目，在 evidence 中注明 "取代 PNNN"
  原则：不删除旧条目，保留进化历史
```

### 10. contradiction_check（矛盾检测）——v2.0 新增

```
触发：准备写入新记忆前
操作：
  1. Grep semantic/ 和 archive/ 查找相关关键词
  2. 检查是否存在矛盾的已有记忆
  3. 如有矛盾：执行 memory_evolve 取代旧记忆，而非平行写入新条目
  4. 如无矛盾：正常写入
```

---

## 会话启动协议（Session Start）

```
1. core_memory_read（4 个 core 块）
2. [可选] working_memory_load（用户提到具体项目时）
3. [可选] semantic_query（遇到重复决策类场景时）
4. 直接开始工作，无需用户重复介绍背景
```

## 会话结束协议（Session End）

```
1. 有重要决策 → archival_memory_insert to decisions.md
2. 有新教训 → archival_memory_insert to lessons.md（带置信度）
              + contradiction_check 先于写入
3. 教训出现 2+ 次 → semantic_distill 提炼为规律
4. 已有规律被验证 → memory_reinforce（reinforced+1）
5. 有项目状态变化 → core_memory_replace in projects.md
6. 有新稳定信息 → core_memory_append to human.md 或 stack.md
```

---

## 记忆质量原则

- **Core = RAM**：精炼、稳定、常用。不写临时状态，不写一次性信息
- **Archive = 日志**：完整、持久、决策理由比结论更重要
- **Semantic = 知识库**：从 Archive 蒸馏而来，有置信度，会进化
- **Working = 工作台**：项目细节，用时加载，不用时不占上下文
- **置信度是约束**：低置信度（<0.7）的规律不应驱动重要决策
- **进化而非删除**：旧记忆通过 superseded_by 标记，不物理删除
- **矛盾优先处理**：发现矛盾立即解决，不让互相矛盾的记忆共存
