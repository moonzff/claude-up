# Skill: task-master
> 工具：eyaltoledano/claude-task-master（25k⭐）· 版本：v1.0 指南
> ⚠️ 需要 Claude Code CLI（`claude` 命令），Cowork 不支持

## 定位

把产品规格（PRD）转为本地结构化任务列表（`tasks/tasks.json`），Claude Code 真正追踪执行状态。
解决大项目中的两个核心问题：
1. **会话失忆**：每次开新会话 Claude 不知道做到哪了
2. **执行循环**：没有任务状态时，Claude 容易重复做已完成的工作

**与 sp-executing-plans 的关系**：
- `sp-executing-plans`：单会话内的顺序执行，适合中小任务
- `task-master`：跨会话的持久化任务管理，适合周级别的大项目

## 安装

```bash
# 在项目目录下初始化
npx task-master-ai init

# 或全局安装
npm install -g task-master-ai
```

## 使用流程

### Step 1 · 准备 PRD 文档

在项目根目录创建 `scripts/prd.txt`，写入产品需求描述：
```
功能目标：...
核心功能：...
技术约束：...
验收标准：...
```

### Step 2 · 生成任务列表

```bash
task-master parse-prd scripts/prd.txt
```

生成 `tasks/tasks.json`（结构化任务 + 依赖关系）和 `tasks/task-NNN.txt`（每个任务的详细文件）。

### Step 3 · 查看任务状态

```bash
task-master list              # 列出所有任务
task-master next              # 下一个可执行任务（依赖已满足）
task-master show <id>         # 查看任务详情
```

### Step 4 · 执行任务

```bash
# 在 Claude Code CLI 中，告诉 Claude 去做哪个任务
# Claude 会读取 task-NNN.txt 并按其规范执行
task-master set-status --id=<id> --status=in-progress
```

执行完成后：
```bash
task-master set-status --id=<id> --status=done
```

### Step 5 · 跨会话继续

下次开新 CLI 会话时：
```bash
task-master list   # 立刻知道哪些任务完成了，下一个是什么
task-master next   # 直接告诉 Claude 继续哪个
```

## 与 Claude_up 的集成

在项目的 CLAUDE.md 或 working/ 文件里注明：

```markdown
## 任务管理
本项目使用 task-master 追踪任务状态。
- 任务文件：`tasks/tasks.json`
- 查看进度：`task-master list`
- 下一个任务：`task-master next`
```

## 适用场景

- 杆杆响会员服务（多功能模块开发）
- quant-trading-system（策略开发 + 回测 + 部署）
- 任何需要 3+ 会话才能完成的项目

## 状态值

| 状态 | 含义 |
|------|------|
| `pending` | 等待执行（依赖未满足或未开始）|
| `in-progress` | 当前正在执行 |
| `done` | 已完成 |
| `deferred` | 延后执行 |
| `cancelled` | 取消 |

## 注意

- `tasks/` 目录建议加入项目的 .gitignore，避免任务状态污染代码仓库
- 或者用单独分支管理任务状态
- task-master 支持 Claude Code CLI，通过 `ANTHROPIC_API_KEY` 或 Claude 订阅调用
