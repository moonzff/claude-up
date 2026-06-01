# Windows → Mac 迁移复盘（Claude Code 环境 + 历史会话）

> 日期：2026-06-01 ｜ 执行：Mac 端 Claude Agent + 用户
> 配套：本目录 `CLAUDE.md`（Mac 版全局记忆）+ `settings.json`（Mac 版配置）
> 交接包：`~/MoonzWorkspace/Archives/ai-env-migration-safe-20260529_135355/claude-code`

本文件记录从 Windows 迁移到 macOS 的完整过程与**踩坑经验**，供以后换机或同类迁移复用。

---

## 1. 迁移范围与结果

| 项目 | 方式 | 结果 |
|---|---|---|
| 6 个 GitHub 仓库 | `git clone`（SSH，代理不稳时重试/keepalive） | ✅ |
| 全局记忆 `CLAUDE.md` | Windows 版改写为 Mac 版（路径/环境/工具链） | ✅ `mac-claude/CLAUDE.md` |
| 5 个斜杠命令 | 拷贝 + 路径 `D:\` → `~/` 改写 | ✅ `~/.claude/commands/` |
| `settings.json` | Mac 版重建（MCP 重配、密钥用 `${env:}`、去 PowerShell hooks） | ✅ `mac-claude/settings.json` |
| 41 个历史会话 transcript | 复制 + 目录改名 + 内部 cwd 改写 | ✅ `~/.claude/projects/` |
| GUI 侧栏会话显示 | 造包装文件 `local_*.json` | ✅ 全部可见 |
| quant-arena 数据路径 | 18 处硬编码 `D:\` → Mac 路径 | ✅ 12 文件 |

---

## 2. 关键架构发现：Claude Desktop 会话的"两层结构"

迁移历史会话时最大的坑：**transcript 文件就位 ≠ 侧栏能看到**。

Claude Desktop 的会话由**两层**组成：

```
层A · CLI transcript（真实对话内容）
  ~/.claude/projects/<编码后的cwd>/<sessionId>.jsonl

层B · GUI 包装文件（侧栏索引/归属）
  ~/Library/Application Support/Claude/claude-code-sessions/
    <账号ID>/<工作区ID>/local_<uuid>.json
```

- **层B 通过 `cliSessionId` 字段链接到层A** 的 transcript。
- 侧栏只渲染**有层B包装文件**的会话；光导入层A的 transcript，侧栏看不到。
- 包装文件的 `cwd` 字段决定会话归属到**哪个项目**——侧栏严格按 cwd 分组。

### 关键字段（层B `local_*.json`）
```
sessionId      : "local_<uuid>"            包装文件自身ID
cliSessionId   : "<uuid>"                   指向层A transcript 文件名（去 .jsonl）
cwd / originCwd: "/Users/moonz/.../项目"    决定侧栏归属
title          : 标题（取自 transcript 的 ai-title/custom-title）
createdAt / lastActivityAt / lastFocusedAt : 毫秒时间戳（取自 transcript）
completedTurns / model / effort / ...      : 其余元数据
```

---

## 3. 多层路径核对（最重要的经验）

> 灵感来自 Codex 迁移复盘：**项目侧栏能否显示历史会话，不只取决于会话是否存在，
> 也取决于每条会话的"项目归属路径"是否在所有索引层都映射到 Mac 本机路径。**

迁移会话后，必须逐层核对 Windows 路径残留：

| 层 | Claude Code 对应 | 检查命令要点 |
|---|---|---|
| 1 transcript cwd | `~/.claude/projects/**/*.jsonl` 内 `"cwd"` 字段 | `grep -rl '"cwd":"D:'` 应为 0 |
| 2 GUI 包装 | `claude-code-sessions/**/local_*.json` 的 `cwd` | 应全为 Mac 路径 |
| 3 项目配置 | `~/.claude.json` 的 `projects` 键 | 键名不含 `D:\`/`\\` |
| 4 IndexedDB | `Application Support/Claude/IndexedDB/*.leveldb` | `strings` 搜 `D:\` 应为 0 |

**注意区分**：transcript 正文里的 `D:\` 路径（出现在 `message.content`、`toolUseResult.filePath`
等字段）是**历史对话内容**，是当年真实记录，**绝不能改**——改了等于篡改聊天历史。
只改"归属用"的 `cwd` 字段。

---

## 4. 操作要点与命令

### 4.1 导入会话（层A）
Windows 编码 `D--MoonzWorkspace-<proj>` → Mac 编码 `-Users-moonz-MoonzWorkspace-<proj>`：
- 目录改名 + 复制（保留源在 history-archive，可回滚）
- 用 Python 改写每个 jsonl 内的 `"cwd":"D:\\MoonzWorkspace..."` → `"/Users/moonz/MoonzWorkspace..."`
- 校验：`grep -rl '"cwd":"D:'` 残留应为 0

### 4.2 造包装文件（层B）
- 模板取自一个已能显示的现有会话（逐字段对齐，19 个字段）
- `cliSessionId` = transcript 文件名去 `.jsonl`
- `cwd`/`title`/时间戳 从 transcript 真实读取
- 写入 `claude-code-sessions/<账号ID>/<工作区ID>/`
- **跳过**已有包装文件的 cliSessionId（避免重复）

### 4.3 跨目录会话合并
某些会话当年在子目录/数据目录（如 `quant-arena-data`）跑，但内容属于主项目。
要合并到主项目侧栏：改包装文件的 `cwd`/`originCwd` 即可（不动 transcript）。

---

## 5. 安全红线（全程遵守）

- **先备份后修改**：每步动 `~/.claude` 或 GUI 库前，先备份到 `~/MoonzWorkspace/Archives/`。
- **不搬密钥**：API key / token / cookie / 凭证一律 Mac 端重配，`settings.json` 用 `${env:VAR}`。
- **不改历史正文**：transcript 里只改归属 `cwd`，不动 `message.content` 等对话内容。
- **可逆**：所有改动都有时间戳备份目录，命令级可回滚。

### 备份目录清单（本次迁移）
```
~/claude-backup-<ts>/                                   原 ~/.claude 整体
~/MoonzWorkspace/Archives/claude-gui-sessions-backup-*  GUI 会话库
~/MoonzWorkspace/Archives/quant-arena-winpath-fix-*     代码路径修复
~/MoonzWorkspace/Archives/quant-arena-session-merge-*   会话合并
```

---

## 6. 仍待办（可选）

- **CRLF 的 .sh**：`ganganxiangPM/.../dashboards-mac/*.sh` 等本该 Mac 跑的脚本是 CRLF 换行，
  会报 `bad interpreter`，需 `dos2unix`。
- **PowerShell hooks → bash**：4 个 hook（pre-bash-audit / post-write-format /
  post-write-research / stop-session-summary）需改写为 bash 后接入 settings。
- **cognee 语义层**：需 `pip install cognee` + 设 `DASHSCOPE_API_KEY` 后重建索引。
- **codegraph MCP**：需装二进制 + 各项目 `codegraph init -i`。
- **Cowork 会话**：迁移包未带 Windows 的 12 个 Cowork 原始 transcript（设计如此，
  知识已提炼进 `CLAUDE_DESKTOP_STATE_AND_SESSION_REPORT`），Mac 端无法还原为可点开会话。

---

*安全：本文件不含任何 API Key、Token、密码。*
