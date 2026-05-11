# Archival Memory · 经验教训日志
> 追加写入，不修改历史记录。新格式含置信度和强化次数（来自 agentmemory 理念）。
> 当一条教训被新场景再次验证时，在 semantic/patterns.md 对应条目更新 reinforced+1。

---

<!-- LES | id: L001 | confidence: 0.95 | reinforced: 1 | date: 2026-05-09 | concepts: [security, token] -->
[2026-05-09] [Claude_up/安全] 不要把 Token/密钥粘贴到对话窗口，即使是和 Claude 的对话也有记录。应该在自己的终端里设置环境变量。
→ 关联规律：C003
<!-- /LES -->

<!-- LES | id: L002 | confidence: 0.95 | reinforced: 1 | date: 2026-05-09 | concepts: [PowerShell, encoding, here-string] -->
[2026-05-09] [Claude_up/部署] PowerShell here-string 对非 ASCII 字符敏感，且 "@ 必须在行首无缩进。有中文内容时改用内联字符串更安全。
→ 关联约定：C001
<!-- /LES -->

<!-- LES | id: L003 | confidence: 0.95 | reinforced: 3 | date: 2026-05-09 | concepts: [Cowork, CLI, MCP, architecture] -->
[2026-05-09] [Claude_up/架构] Cowork 桌面工具体系 ≠ Claude Code CLI 工具体系。settings.json 的 mcpServers 只对 CLI 生效。新功能要先确认目标环境再配置。
→ 关联规律：P001
<!-- /LES -->

<!-- LES | id: L004 | confidence: 0.85 | reinforced: 1 | date: 2026-05-10 | concepts: [dependency, binary-installer, risk] -->
[2026-05-10] [Claude_up/工具引入] 外部运行时的二进制安装器（curl | sh 类型）是比 npm 包高一级的依赖风险。如果提供方停止维护或关闭，工具完全失效。评估工具时需要单独考虑这类依赖。
→ 关联规律：P002（服务依赖风险）
<!-- /LES -->

<!-- LES | id: L005 | confidence: 0.82 | reinforced: 2 | date: 2026-05-10 | concepts: [research, tool-adoption, extract-vs-install] -->
[2026-05-10] [Claude_up/工具引入] 调研工具时，"提取有价值的设计理念 + 不整体安装"往往比直接安装收益更高、风险更低——尤其对小型/新兴项目。superpowers-zh（22⭐）和 agentmemory（290⭐）都用了这个框架，结果良好。
→ 关联规律：P004（外部工具成熟度评估）
<!-- /LES -->

---

## 新增教训格式

```
<!-- LES | id: LNNN | confidence: 0.X | reinforced: N | date: YYYY-MM-DD | concepts: [tag1, tag2] -->
[YYYY-MM-DD] [项目/场景] 教训内容描述。
→ 关联规律/约定：PNNN / CNNN（如果已有对应条目）
<!-- /LES -->
```

**confidence 参考**：
- 0.95+ = 多次验证，确定无疑
- 0.80–0.94 = 有证据，但场景有限
- 0.60–0.79 = 初次观察，需要更多验证
