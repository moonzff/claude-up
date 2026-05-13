# Tooling — 周边工具

Claude_up 本体之外，以下工具可以增强日常使用体验。这些工具不需要安装到 Claude_up 中，独立使用。

| 工具 | 用途 | 文档 |
|------|------|------|
| [ccusage](./ccusage.md) | Token 用量和成本追踪 | `npx ccusage daily` |
| [token-efficiency](./token-efficiency.md) | Token 效率策略指南 | 置信度检查 + 预算分级 + Wave 并行 |

## 社区 Skill 发现

Claude Code 的 Skill 是开放标准，社区有大量已制作好的 Skill 包可以按需安装：

```bash
# 交互式安装社区 Skill 包（选择需要的 Skill，不必全装）
npx skills add <github-username>/<repo-name>

# 示例：
npx skills add iamzhihuix/happy-claude-skills   # 媒体生成、浏览器自动化等
```

**搜索入口**：
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) — Skills 分类索引
- GitHub 搜索 `topic:claude-code-skills`

**选装原则**（参考 P004 规律）：按需选装，避免功能高度重叠的整包安装。

## Git Worktree — 并行多会话模式

在 Claude Code CLI 环境下，可以用 `git worktree` 在同一仓库的不同分支上同时跑多个 Claude Code 会话，互不干扰：

```bash
# 创建新 worktree（单独目录，指向新分支）
git worktree add ../my-project-feature feature/new-thing

# 在新目录中启动第二个 Claude Code 会话
cd ../my-project-feature
claude

# 查看当前所有 worktree
git worktree list

# 清理（合并/废弃后）
git worktree remove ../my-project-feature
```

**适用场景**：
- 主分支 Claude 写代码，功能分支 Claude 同时写测试
- 两个独立功能并行开发，各自跑 Agent 不冲突
- 长时间 Agent 任务挂后台，前台继续交互

**限制**：需要 Claude Code CLI（`claude` 命令），Cowork 模式不适用。

来源：[shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice)（52.7K⭐）

---

## 计划中

| 工具 | 用途 | 状态 |
|------|------|------|
| claude-task-master | 跨会话任务持久化（大项目防循环）| 待 pilot 评估（需 CLI 环境）|
