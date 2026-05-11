# MCP 扩展选型报告（Phase 13）

> 更新：2026-05-11
> 参考：awesome-mcp-servers（86.7k⭐）

---

## 当前 MCP 状态

| MCP | 状态 | 用途 |
|-----|------|------|
| filesystem | ✅ 激活 | 本地文件读写（D:\MoonzWorkspace） |
| playwright | ✅ 激活 | 浏览器自动化 |
| context7 | ✅ 激活 | 实时库文档查询 |
| github | ⚙️ 待激活 | 需设置 GITHUB_TOKEN |
| letta | ⚙️ 待激活 | 需本地 Letta 服务 |

---

## 项目需求分析

### 杆杆响会员服务

**技术栈**（推测）：Node.js + 关系型数据库
**MCP 需求**：
- 数据库查询（会员数据分析、活动统计）
- 可能的 CRM/支付系统集成

### quant-trading-system

**技术栈**：Python + 量化数据
**MCP 需求**：
- 金融市场数据（A股/期货/加密货币）
- 回测数据访问

---

## 选型建议

### 方案 A：杆杆响 — 数据库 MCP

**推荐**：`@modelcontextprotocol/server-sqlite` 或 `mcp-server-mysql`

| 选项 | 优势 | 劣势 | 适用 |
|------|------|------|------|
| SQLite MCP | 零依赖，官方维护 | 仅限 SQLite | 本地开发环境 |
| MySQL MCP | 主流数据库 | 需要 DB 连接信息 | 生产数据库 |
| PostgreSQL MCP | 功能最完整 | 配置稍复杂 | 如使用 PG |

**配置示例（MySQL）**：
```json
"mysql": {
  "command": "npx",
  "args": ["-y", "mcp-server-mysql"],
  "env": {
    "MYSQL_HOST": "${env:MYSQL_HOST}",
    "MYSQL_USER": "${env:MYSQL_USER}",
    "MYSQL_PASSWORD": "${env:MYSQL_PASSWORD}",
    "MYSQL_DATABASE": "${env:MYSQL_DATABASE}"
  }
}
```

**激活前提**：
- [ ] 确认杆杆响使用的数据库类型（MySQL/PG/SQLite）
- [ ] 在 Windows 环境变量设置 DB 连接信息
- [ ] 测试只读权限（不要给写权限）

---

### 方案 B：quant-trading — 金融数据 MCP

**选项 1：Tushare MCP**（A 股专属）

适合：A 股日线数据、财务数据、指数成分
- npm: 暂无官方 MCP，需自建或用 Python 脚本包装
- 替代：直接用 filesystem MCP 读取本地 Tushare 数据文件

**选项 2：Yahoo Finance MCP**（美股/ETF）

适合：美股、ETF、加密货币实时数据
```bash
npx -y @modelcontextprotocol/server-yahoo-finance
```

**选项 3：通用 HTTP/REST MCP**

适合：对接任意金融数据 API（掘金量化、Baostock、AKShare）
```json
"http-client": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-fetch"]
}
```

**推荐路径**：
1. 先用 filesystem MCP 读取已有的本地数据文件（零成本，立即可用）
2. 等项目进入活跃开发阶段，再接入专用金融数据 MCP

---

## 其他值得关注的 MCP

| MCP | 功能 | 适用场景 |
|-----|------|---------|
| Sequential-thinking | 多步推理，减少 30-50% Token | 复杂分析任务 |
| Serena | 会话持久化和记忆 | 长期项目，补充 08-memory/ |
| Slack MCP | Slack 消息读写 | 如果杆杆响用 Slack 运营 |
| Notion MCP | Notion 数据库读写 | 知识库管理 |

---

## 行动计划

| 优先级 | 行动 | 前提条件 |
|--------|------|---------|
| 🔴 近期 | 激活 GitHub MCP | 设置 GITHUB_TOKEN 环境变量 |
| 🟡 中期 | 接入数据库 MCP（杆杆响） | 确认 DB 类型 + 只读账号 |
| 🟡 中期 | filesystem 读取本地量化数据（quant） | 确认数据文件路径 |
| 🟢 远期 | Sequential-thinking MCP | Token 优化需求明确后 |
| 🟢 远期 | 专用金融数据 MCP | quant 项目进入活跃开发 |

---

## 参考资源

- [awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers) — MCP 主目录（86.7k⭐）
- [MCP 官方 Servers](https://github.com/modelcontextprotocol/servers) — Anthropic 维护的官方 MCP
- `05-mcp/github.json` — GitHub MCP 配置文档
- `05-mcp/letta.json` — Letta MCP 配置文档
