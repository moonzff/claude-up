# Archival Memory · 技术决策日志

> 追加写入，不修改历史记录。格式：[日期] [项目] 决策内容 · 原因

---

[2026-05-07] [Claude_up] 使用 SKILL.md 作为技能载体 · 原因：跨工具通用，纯文本无依赖
[2026-05-07] [Claude_up] settings.json 权限用白名单+黑名单双层 · 原因：安全默认，防止误操作
[2026-05-07] [Claude_up] 部署脚本默认 dry-run · 原因：批量写操作必须先预览确认
[2026-05-08] [Claude_up] grill-plan 升级为 Ouroboros 演化循环（Interview→Seed→Execute→Evaluate）· 原因：解决执行中发现需求变化无处理的问题
[2026-05-09] [Claude_up] settings.json mcpServers 只对 CLI 生效，Cowork 独立体系 · 原因：调研确认，架构边界清晰
[2026-05-09] [Claude_up] 08-memory/ 文件记忆替代 Letta 服务 · 原因：Cowork 无法访问 Windows localhost，文件方案今天就能用
[2026-05-09] [Claude_up] install_claude_app.ps1 here-string 改为内联字符串 · 原因：中文字符 + PowerShell here-string 编码兼容问题
[2026-05-10] [Claude_up] superpowers-zh（22⭐）→ 提取 systematic-debugging + verification-before-completion 两个 Skill，不整体安装 · 原因：14/19 个 Skill 与现有库重叠，整体引入是噪音
[2026-05-10] [Claude_up] agentmemory（290⭐）→ 吸收四层架构 + 置信度 + 记忆进化等设计理念，不安装服务 · 原因：iii-engine 外部依赖风险 + Hooks 在 Cowork 不触发
[2026-05-10] [Claude_up] 08-memory/ 升级为四层架构（v0.9.0）：Core/Working/Semantic/Archive · 原因：吸收 agentmemory 的规律蒸馏和置信度评分理念，纯文件实现无外部依赖
[2026-05-18] [ganganxiangPM] OA 多端架构 P1 收口：cron 全迁 Mac mini（7×24），代码 Git 主端 + Win/Mac 双拉，看板原地生成原地服务（HR_REPORTS_DIR env + scripts._paths）。Win 不再跑业务 cron。详情：project-docs/plans/20260518_architecture_and_workflow.md
[2026-05-18] [ganganxiangPM] 5/18 17:45-20:45 经营会议决策：小张晋升 P2 (1.5x 指标 / 6010 月薪)；小戴转岗虚拟技术支持（不考核业绩）；余熠转产品岗（KPI = 需求表完成率）；销售部目标 35w 拆 4 人，转化率 5%；周三周会、周五管理层；5/19 前各部门考核指标定版。来源：HR/K 知识/K2 决策档案/05-18+工作事务汇总.md
[2026-05-18] [ganganxiangPM] 试岗中 = 万博/周牧/余熠（已写入 onboarding_records，promotion 试岗 3 个月观察期，5/31 / 6/30 / 7/31 三检查点）
