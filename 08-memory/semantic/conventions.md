# Semantic Memory · 约定惯例库
> 在此项目环境下已确定的编码/工作流约定。confidence 表示遵循的稳定程度。
> 操作：发现新约定 → 追加；约定变更 → 添加 superseded_by

---

<!-- CONV | id: C001 | confidence: 0.95 | domain: PowerShell | last: 2026-05-09 -->
## [C001] PowerShell 字符串：含中文用内联，不用 here-string
**约定**：PowerShell 脚本中含中文内容时，使用内联反引号字符串（`` "`n...内容..." ``），
不使用 here-string（`@"..."@`）。
**原因**：here-string 的 `"@` 对行首缩进敏感，含中文时编码问题导致解析失败。
**示例**：
```powershell
# ❌ 易出错
$msg = @"
中文内容
"@
# ✅ 安全
$msg = "`n中文内容`n"
```
<!-- /CONV -->

---

<!-- CONV | id: C002 | confidence: 0.90 | domain: Claude_up/文件命名 | last: 2026-05-09 -->
## [C002] 研究档案命名：YYYY-MM-DD_research_vX.Y_描述.md
**约定**：研究类文档统一格式：`YYYY-MM-DD_research_v版本_描述词.md`
**路径**：`D:\MoonzWorkspace\Research\Claude_up\`
**示例**：`20260507_research_v0.1_environment-survey.md`
<!-- /CONV -->

---

<!-- CONV | id: C003 | confidence: 0.85 | domain: Claude_up/部署 | last: 2026-05-09 -->
## [C003] 配置文件不硬编码敏感值
**约定**：settings.json 及所有配置文件中，API Key/Token/密码一律用 `${env:VAR}` 占位符。
真实值只在操作系统环境变量中设置，不在任何文档或对话中出现。
**触发场景**：GitHub Token、Anthropic API Key、数据库密码
<!-- /CONV -->

---

<!-- CONV | id: C004 | confidence: 0.90 | domain: SKILL.md/格式 | last: 2026-05-09 -->
## [C004] SKILL.md 结构：定位 → 流程 → 输出物 → 原则
**约定**：所有 SKILL.md 遵循统一结构：
1. `## 定位` — 一句话说清楚这个 Skill 解决什么问题
2. `## 执行流程` — 分步骤（Phase 或 Step）
3. `## 输出物` — 交付什么
4. `## 原则` — 约束和禁止项
**原因**：统一结构让 Claude 更快解析和执行，也让维护更容易
<!-- /CONV -->

---

<!-- CONV | id: C005 | confidence: 0.80 | domain: Git | last: 2026-05-09 -->
## [C005] Git 操作白名单
**约定**：以下 Git 操作必须用户显式确认后才执行：
- `git push`（任何 push，尤其是 --force）
- `git reset --hard`
- `git rebase -i`（涉及已推送提交时）
- `git filter-repo`（历史重写）
**说明**：这些操作不可逆或影响他人，不在 Claude 自主范围内
<!-- /CONV -->

---

## 添加新约定

格式：
```
<!-- CONV | id: CNNN | confidence: 0.X | domain: 领域 | last: YYYY-MM-DD -->
## [CNNN] 约定名称
**约定**：具体规则
**原因**：为什么
**示例**：（可选）
<!-- /CONV -->
```
