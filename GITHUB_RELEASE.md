# GitHub 发布指南 · v0.9.0

> 此文件在推送后可以删除（或保留作为内部参考）。

## 步骤 1：在 GitHub 上创建新仓库

1. 打开 https://github.com/new
2. 填写：
   - Repository name: `claude-up`
   - Description: `A reproducible, auditable Claude Code environment governance toolkit. Dual-scenario: deep software engineering + personal digital assistant.`
   - Visibility: **Public**
   - ⚠️ **不要勾选** "Add a README file"（我们有自己的）
   - ⚠️ **不要勾选** "Add .gitignore"（我们有自己的）
   - License: None（我们已有 LICENSE 文件）
3. 点击 "Create repository"

## 步骤 2：在本地初始化 Git 并推送

在 PowerShell 中执行（把 `YOUR_GITHUB_USERNAME` 替换为你的用户名）：

```powershell
cd D:\MoonzWorkspace\Claude_up

# 初始化 Git 仓库
git init
git branch -M main

# 配置（如果还没配置过）
git config user.name "Moonz"
git config user.email "harrisding2026@gmail.com"

# 添加所有文件（.gitignore 会自动排除个人数据）
git add .

# 确认要提交的文件（检查没有个人信息）
git status

# 初始提交
git commit -m "feat: Claude_up v0.9.0 initial public release

- Dual-scenario coverage: engineering dev + personal assistant
- 8 always-active skills + 10 on-demand skill library
- 4-tier memory system with confidence scoring and memory evolution
- 4 deterministic hooks + 5 MCP configs
- Bilingual README (EN + ZH)
- MIT License"

# 关联远程仓库并推送
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/claude-up.git
git push -u origin main
```

## 步骤 3：创建 GitHub Release

推送成功后：
1. 打开 `https://github.com/YOUR_GITHUB_USERNAME/claude-up/releases/new`
2. Tag: `v0.9.0`
3. Release title: `v0.9.0 — Initial Public Release`
4. 描述（复制以下内容）：

```markdown
## Claude_up v0.9.0 — Initial Public Release

A reproducible, auditable Claude Code environment governance toolkit.

### What's included

- **10 on-demand skills** (skill library): sp-brainstorming, sp-writing-plans, sp-executing-plans, sp-tdd, systematic-debugging, verification-before-completion, code-review, security-audit, api-design, task-master
- **8 always-active skills**: grill-plan v2 (Ouroboros loop), diagnose, dual-environment-workflow, research-object-archive, summarize-meeting, weekly-review, memory-update
- **4-tier memory system** with confidence scoring, memory evolution, and contradiction detection
- **4 deterministic hooks** + 5 MCP server configs
- **Bilingual README** (EN + ZH)
- **MIT License**

### Quick Start

```powershell
git clone https://github.com/YOUR_USERNAME/claude-up.git
cd claude-up
.\06-deployment-kit\install_claude_app.ps1  # dry-run
.\06-deployment-kit\install_claude_app.ps1 -Execute -Profile full
.\cli\claude_app.ps1 doctor
```
```

## 推送前安全检查

运行以下命令确认没有个人信息被纳入提交：

```powershell
# 确认 gitignore 生效
git status --short | Where-Object { $_ -match "human|projects|working" }
# 应该没有输出

# 查看将被提交的文件列表
git ls-files | Select-String "memory"
# 应该只看到：
# 08-memory/archive/decisions.md
# 08-memory/archive/events.md
# 08-memory/archive/lessons.md
# 08-memory/core/persona.md
# 08-memory/core/stack.md
# 08-memory/semantic/conventions.md
# 08-memory/semantic/patterns.md
# 08-memory/templates/README.md
# 08-memory/templates/human.template.md
# 08-memory/templates/projects.template.md
# 08-memory/templates/working.template.md
# 不应出现：human.md / projects.md / working/
```
