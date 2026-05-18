# Claude_up 部署检查清单

> 版本：v1.1 | 日期：2026-05-18 | 新增：Phase 8 cognee 语义记忆层

---

## 部署流程：Dry-run → Review → Apply → Verify

### Step 1：干跑（Dry-run，默认）

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "D:\MoonzWorkspace\Claude_up\06-deployment-kit\install_claude_app.ps1"
```

预期输出：
- `[DRY-RUN]` 前缀的操作列表
- 所有将被创建/覆盖的文件路径
- 没有任何实际文件被修改

### Step 2：审核（Review）

在执行前，确认以下事项：

- [ ] `settings.json` 内容是否符合预期（无硬编码密钥）
- [ ] `CLAUDE.md` 内容是否符合预期（身份、原则、禁止清单）
- [ ] 目标路径 `~/.claude/` 是否正确
- [ ] 是否有需要保留的现有 `~/.claude/settings.json` 或 `CLAUDE.md`（先备份）

### Step 3：执行（Apply）

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "D:\MoonzWorkspace\Claude_up\06-deployment-kit\install_claude_app.ps1" -Execute
```

预期输出：
- `[COPY]` 或 `[CREATE]` 前缀的操作日志
- 每个文件的源路径 → 目标路径
- 最终 `[DONE]` 确认

### Step 4：验证（Verify）

```powershell
# 确认文件存在
Test-Path "$env:USERPROFILE\.claude\settings.json"
Test-Path "$env:USERPROFILE\.claude\CLAUDE.md"

# 查看内容（确认无意外变更）
Get-Content "$env:USERPROFILE\.claude\settings.json"
Get-Content "$env:USERPROFILE\.claude\CLAUDE.md" | Select-Object -First 20
```

在 Claude Code 中验证：
```bash
claude doctor
claude mcp list
```

---

## 回滚方式

如果部署后出现问题：

```powershell
# 删除全局配置（回到零状态）
Remove-Item "$env:USERPROFILE\.claude\settings.json" -Force
Remove-Item "$env:USERPROFILE\.claude\CLAUDE.md" -Force

# 或恢复备份
Copy-Item "$env:USERPROFILE\.claude\settings.json.bak" "$env:USERPROFILE\.claude\settings.json"
Copy-Item "$env:USERPROFILE\.claude\CLAUDE.md.bak" "$env:USERPROFILE\.claude\CLAUDE.md"
```

---

## 已知约束

- `~/.claude/` 是受保护路径，不能通过 Cowork `request_cowork_directory` 挂载
- 部署必须通过 PowerShell 脚本（`Copy-Item`）或手动复制
- 脚本默认 dry-run，必须传 `-Execute` 才会真正写入
- 每次修改模板后，需要重新运行部署脚本

---

---

## Phase 8：cognee 语义记忆层（补充部署步骤）

### cognee 安装

```powershell
# 预览
.\06-deployment-kit\install-cognee.ps1

# 确认后执行
.\06-deployment-kit\install-cognee.ps1 -Execute
# 或双击：06-deployment-kit\install-cognee.bat
```

### 部署更新后的 settings.json（含 cognee MCP）

```powershell
.\06-deployment-kit\install_claude_app.ps1 -Execute
```

### 验证 cognee MCP 接入

```bash
# 在 Claude Code CLI 中
claude mcp list   # 应看到 cognee
```

在 Claude 会话中：
```
cognee_remember("Claude_up 项目：Moonz 的 Claude Code 环境治理工具包，部署在 D:\MoonzWorkspace\Claude_up")
cognee_recall("Claude_up")   # 应返回刚存入的记忆
```

### 首次记忆导入（可选）

将现有 `08-memory/archive/` 历史记录批量导入 cognee，在 Claude 会话中说：
```
读取 08-memory/archive/decisions.md 和 lessons.md，
用 cognee_remember 逐条存入历史记录
```

---

---

## Phase 8B：codegraph 代码库语义索引（补充部署步骤）

### 安装（双击即可）

```
D:\MoonzWorkspace\Claude_up\06-deployment-kit\install-codegraph.bat
```

或手动：
```powershell
npm install -g @colbymchenry/codegraph
npx @colbymchenry/codegraph   # 交互式配置，自动写入 Claude Code MCP
```

### 重新部署 settings.json（含 codegraph MCP）

```powershell
.\06-deployment-kit\install_claude_app.ps1 -Execute
```

### 初始化各项目（每个代码仓库执行一次）

```powershell
cd D:\MoonzWorkspace\<project>
codegraph init -i    # 构建索引，约 1-4 分钟
codegraph status     # 验证
```

### 与 cognee 的分工

| 工具 | 解决什么问题 | 数据范围 |
|------|------------|---------|
| cognee | 跨会话的人/项目/决策记忆 | 对话内容、知识 |
| codegraph | 代码库结构理解，减少 grep | 源代码符号图谱 |

---

## 版本记录

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.2 | 2026-05-18 | Phase 8B：codegraph 代码库语义索引 |
| v1.1 | 2026-05-18 | Phase 8：cognee 语义记忆层，替代未激活的 letta |
| v1.0 | 2026-05-07 | 初始版本，Phase 1 基线 |
