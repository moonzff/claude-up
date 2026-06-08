# Semantic Memory · 规律模式库
> 从跨会话经验中提炼的稳定规律。每条规律有置信度（0.0–1.0），被新证据强化时提升。
> 操作：新规律 → 追加；被反驳 → 添加 superseded_by；强化 → 更新 confidence + reinforced

---

<!-- PAT | id: P001 | confidence: 0.95 | reinforced: 4 | last: 2026-06-08 -->
## [P001] 环境边界优先验证
**规律**：引入任何新工具/MCP/服务前，必须先确认它在目标执行环境（Cowork vs CLI）里能运行。
**证据**：
- Letta MCP → Cowork 无法访问 localhost:8283（教训+1）
- settings.json mcpServers → 实测 Claude Code v2.1.x **根本不读**（旧"只对 CLI 生效"认知已被 L024 推翻）；MCP 须 `claude mcp add` → `~/.claude.json`（教训+1，2026-06-08 强化）
- agentmemory Hooks → 只在 CLI 触发，Cowork 无效（教训+1）
**行动**：每次决策是否安装某工具时，第一个问题："在 Cowork 里能用吗？"
<!-- /PAT -->

---

<!-- PAT | id: P002 | confidence: 0.88 | reinforced: 2 | last: 2026-05-09 -->
## [P002] 服务依赖风险 > 文件方案收益
**规律**：在 Cowork 主场景下，需要运行本地服务的工具（Letta/agentmemory/Docker）成本高于收益。文件方案 + 协议约束能覆盖 70-85% 的功能价值，且零依赖、永远可用。
**证据**：
- Letta：功能强但需要 localhost:8283 → 改用 08-memory/ 文件实现（教训+1）
- agentmemory：自动捕获好但 Hooks 在 Cowork 不触发 → 吸收设计理念不安装（教训+1）
**行动**：调研阶段就评估"这个工具在 Cowork 里是否 zero-config 可用"
<!-- /PAT -->

---

<!-- PAT | id: P003 | confidence: 0.90 | reinforced: 2 | last: 2026-05-09 -->
## [P003] 批量写操作必须干跑先行
**规律**：任何批量文件操作（部署/迁移/安装）先输出预演报告，确认无误再执行。
**证据**：
- install_claude_app.ps1 默认 dry-run 参数设计（预防+1）
- deploy_execute.bat 因 here-string 报错，如果没有干跑机制会直接损坏配置（教训+1）
**行动**：部署类脚本必须提供 `-DryRun` 参数，默认启用
<!-- /PAT -->

---

<!-- PAT | id: P004 | confidence: 0.88 | reinforced: 3 | last: 2026-05-13 -->
## [P004] 外部开源工具的成熟度评估
**规律**：满足以下任一条件的工具，调研价值 > 直接安装价值：① Stars < 500 或 Commits < 50；② 依赖外部服务/运行时（curl|sh 安装器、私有服务器）；③ 与现有工具功能高度重叠。有用的设计理念可以提取，但整体引入风险高。
**证据**：
- superpowers-zh（22⭐）→ 提取 2 个 Skill，不整体安装（+1）
- agentmemory（290⭐, iii-engine 依赖）→ 吸收理念，不安装（+1）
- happy-claude-skills（287⭐, 14 commits, 单作者）→ 提取架构理念 + 多提供商模式，不安装（+1）
**行动**：新工具调研用"提取价值 vs 直接安装"框架判断
<!-- /PAT -->

---

<!-- PAT | id: P005 | confidence: 0.82 | reinforced: 1 | last: 2026-05-13 -->
## [P005] 多提供商统一接口抽象
**规律**：当需要调用多个同类 API 提供商（不同 LLM / 不同数据源 / 不同生成服务）时，在调用方和供应商之间引入统一接口层，使切换供应商不影响上层代码。
**证据**：
- happy-claude-skills 的 happy-image-gen：统一封装 8 个图像生成提供商，调用方无感知切换（+1）
- 适用场景识别：quant-trading 多 LLM 评议（POLO/OPENROUTER/本地模型）同构
**行动**：quant-trading 多 LLM 评议模块设计时，优先采用统一接口层，而非直接调用各厂商 SDK
<!-- /PAT -->

---

## 添加新规律

格式：
```
<!-- PAT | id: PNNN | confidence: 0.X | reinforced: N | last: YYYY-MM-DD -->
## [PNNN] 规律名称
**规律**：一句话描述
**证据**：- 具体事件（教训+1 / 预防+1）
**行动**：遇到类似场景的决策准则
<!-- /PAT -->
```
