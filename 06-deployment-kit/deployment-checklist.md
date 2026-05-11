# Claude_up 部署检查清单

> 版本：v1.0 | 日期：2026-05-07

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

## 版本记录

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0 | 2026-05-07 | 初始版本，Phase 1 基线 |
