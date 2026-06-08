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

<!-- LES | id: L006 | confidence: 0.95 | reinforced: 1 | date: 2026-05-20 | concepts: [agent-safety, authorization, auto-merge, git-push, ambiguity] -->
[2026-05-20] [quant-arena/agent-safety] "继续" / "continue" 是**模糊授权信号**，不应被 agent 解读为对 destructive/shared-state 操作（merge to main、git push --force、rm -rf 等）的授权。明确禁止操作列表参考 CLAUDE.md `Do Not Do` 节。当 agent 不确定时，**必须 AskUserQuestion 显式确认**，而不是基于 pattern-match（"上次你说继续是这意思"）自行推断。
具体案例：2026-05-20 38ec44e7 会话中，agent 在 `gh pr merge 228 --squash --delete-branch` 前只看到两次 "继续" 文字（一次实际是 "look it over, then continue"，另一次是 token），就自行 merge 了 PR #228 到 main。事后 AskUserQuestion 时用户确认 future rule 为 "always confirm explicitly"。Auto-mode classifier 本身对 merge-to-default-branch 抛过 warning，但 agent 还是过了。
→ 关联约定：CLAUDE.md global "Do Not Do" §git push / git reset / rm -rf 三件套
→ 反向证据：本次 incident 之后用户在 AskUserQuestion 显式答 "always confirm explicitly" — 加强证据。
<!-- /LES -->

<!-- LES | id: L007 | confidence: 0.90 | reinforced: 3 | date: 2026-05-21 | concepts: [mypy, pandas-stubs, python-3.10, type-narrow] -->
[2026-05-21] [quant-arena/mypy-strict] **Mypy 3.10 比 3.11+ 更严**，本地 venv (3.11) 过 ≠ CI (3.10/3.11/3.12 矩阵) 过。三个通用修法：(1) `pd.Series.reindex(Sequence[str])` 报 SequenceNotStr → `series.reindex(list(universe))`，pandas-stubs 不接受裸 `Sequence[str]`；(2) `panel.loc[Timestamp]` / `multi_indexed.xs(key)` 返回 `Series | DataFrame` → `isinstance(row, pd.Series)` 收窄 + 非 Series 路径 raise `FactorCalculationError`；(3) `np.ndarray` 泛型 (`Missing type arguments for generic type`) → `import numpy.typing as npt` + `npt.NDArray[np.float64]`。本 Session 在 #235/#239/#240 三个 PR 各踩一次。
→ 关联约定：CI matrix 必须本地多版本 mypy 验证；不能只跑 default venv。
<!-- /LES -->

<!-- LES | id: L008 | confidence: 0.92 | reinforced: 1 | date: 2026-05-21 | concepts: [git, squash-merge, cascade, conflict-resolution] -->
[2026-05-21] [quant-arena/git-cascade] **GitHub squash-merge 串行链的冲突分类规则**（13 PR 级联实战验证）：每个 PR rebase 到 main 时，把冲突文件分两类：(a) **本 PR 自己 OWN 的文件** → `git checkout --ours`（PR 在该文件上有独立贡献）；(b) **upstream 已经 squashed 进 main 的"继承"文件** → `git checkout --theirs`（main 是 post-squash 权威版本）。判定标准：`git log origin/main..origin/<pr-branch> --name-only` 列出 PR 独有 commits 的文件清单，**不在该清单的就是 inherited**。错用 `--ours` 会把 main 已 land 的 CI fix 重新覆盖回旧版本。本次 #239 mock_source.py 应 `--theirs`（main 已含 isinstance narrow）；#240 `__init__.py` 应 `--ours`（owns Phase5FactorSource export）。
→ 关联规律：squash-merge 后 commit SHA 变化，post-squash main 是不可逆的新权威，所有 downstream PR 都按"以 main 为准 + 加上本 PR 独有的"原则合并。
<!-- /LES -->

<!-- LES | id: L009 | confidence: 0.85 | reinforced: 1 | date: 2026-05-21 | concepts: [import-isolation, core-markets, architecture] -->
[2026-05-21] [quant-arena/arch] **core/ ↛ markets/ 导入隔离规则的破口**：`core/factors/phase5_source.py` 一旦 `import markets.cn_a_share.factors`（即使在函数体里 lazy import），governance/import-isolation CI 仍然失败——因为它 grep AST 不是 grep 顶层 import。修法：把 "wiring layer"（registry build + bars_loader wrapping）抽到 `markets/cn_a_share/factors/_phase5_wiring.py`，core/ 只承诺 `BarsLoader = Callable[[date, Sequence[str], int], pd.DataFrame]` 这种 Callable 接口。同理 Phase E 任何 production wrapping 必须遵循同模式。
→ 关联约定：Protocol/Callable 接口属于 core；任何 markets-specific instantiation 属于 markets。
<!-- /LES -->

<!-- LES | id: L010 | confidence: 0.95 | reinforced: 1 | date: 2026-05-21 | concepts: [factor, ic-sign, decile-ls, rank-correlation, methodology] -->
[2026-05-21] [quant-arena/methodology] **Rank IC 与 decile-spread sign 可以反号**：因子-收益关系在 universe 极端 10% 可能与中段 80% 走相反方向（non-monotonic at tails）。Rank IC 测的是整个 universe 的 monotonic 趋势；decile-LS engine 只在 top/bottom decile 操作。**结论：decile-LS 的 ic_sign 必须用 decile-spread 测，不能用 rank IC**。本会话 Phase B v1 用 rank IC 锁 sign → 5y Sharpe -2.98；v2 用 decile-spread + per-year 验证 sign → Sharpe +2.98（符号完全相反）。同样：top-N LO engine 用 "top-N 平均 forward return vs universe mean" 测，不能用 rank IC。
→ 关联规律：因子 IC 测量类型必须匹配实际的 portfolio construction 方法。methodology doc 必须 cite 测量类型 + 窗口 + universe + N。
→ 反向证据：因为 v2 的 sign 翻转后 3 个独立年份（2022/2023/2024）M1+M2 全部 strong positive Sharpe，6/6 独立测试胜出，confidence ≥ 0.95
<!-- /LES -->

<!-- LES | id: L011 | confidence: 0.90 | reinforced: 1 | date: 2026-05-21 | concepts: [no-go-gate, doctrine, wiring-fix, search-loop, falsifiability] -->
[2026-05-21] [quant-arena/doctrine] **No-go-gate doctrine 区分 "search loop"（禁）vs "wiring contract bug fix"（允许）的判据**：(1) **修正值是否唯一确定** — 给定预承诺意图，新值是否由 production pipeline 测量唯一锁死、无 DOF？(2) **失败原因是否独立于 strategy logic** — 是 wiring bug 还是 strategy 本身不 work？(3) **是否存在事后选择偏差** — 改动是发现 bug 一瞬间就完全确定的，还是看了多个候选回测后才选的？只有 (1) ∧ (2) ∧ ¬(3) 同时满足才属 wiring fix。G3-4 14/14 unanimous APPROVE 本会话 sign-flip retry 走这条判据。
→ 关联约定：doctrine §3 forbidden patterns 仍然限制 weight tuning / factor swap / sign 试错；wiring fix 是 doctrine 的 explicit escape hatch（架构 trace audit 后允许）。
→ 反向证据：v2 sign-flip retry 经 architecture audit 走 G3-4，14/14 unanimous APPROVE。doctrine 保留 escape hatch 行为正确。
<!-- /LES -->

<!-- LES | id: L012 | confidence: 0.92 | reinforced: 1 | date: 2026-05-21 | concepts: [audit, sample-size, regime-bias, generalization] -->
[2026-05-21] [quant-arena/audit-design] **短窗口 audit PASS 必须有 long-window followup gate**。3-month slice 上 BULL-biased（62% BULL）的 sample 可以让 M_3 prototype 显示 PASS verdict (incremental Sharpe +0.665)；3-year slice 上 BEAR-dominated（87% BEAR）的 reality 让 verdict 反转到 FAIL (-0.371)。**Cross-regime persistence ≥ 2/3 regimes** 是必要的第二道闸门，避免 short-window sample bias 错误地通过 standalone-engine 架构。M15 memo §3.4 早就预言了这个 failure mode 并 mandated 了 3y E.7b precursor — 这次实战完美验证。
→ 关联规律：任何 OOS slice < 2 years 都要按 cross-regime persistence 检验；audit 设计阶段必须 pre-commit followup criterion，不能在 short-window PASS 后再补加。
→ 反向证据：M15 3m PASS (#251) → 3y FAIL (#252)，验证 memo §3.4 设计的 mandated followup 是正确的安全机制。
<!-- /LES -->

<!-- LES | id: L013 | confidence: 0.88 | reinforced: 1 | date: 2026-05-21 | concepts: [architecture, absorbed-vs-standalone, redundancy-audit, correlation-gate] -->
[2026-05-21] [quant-arena/architecture] **High cross-modality correlation (> 0.6) 说明 standalone engine architecture 是 duplicative，应 ABSORB 到上游 layer**。M_3 regime-conditional aggregation 在 4 因子 LS engine 上和 baseline M_LS 的 correlation 一直在 0.71-0.72 (3m + 3y 两个窗口都高)，说明用 SAME 因子 + SAME M_LS engine 的 regime-conditional weighting 只能在边缘改变 position weights，本质上 emit 相似的 portfolio。结论：regime-conditional aggregation 该在 Phase 5 HSA Layer 3（applied uniformly per-cell）实现，而不是当 M-Layer engine。M-Layer surface 应保留给真正 fundamentally different 的 signal-generation modes（top-N concentration / 不同 rebal cadence / cash floor）。
→ 关联约定：架构决策审计必须看 cross-modality correlation；> 0.6 是 ABSORB 信号，不只是"flag"。
→ 反向证据：Phase E 通过 M15 audit (#252) 把 M_3 ABSORBed into Phase 5 HSA Layer 3；M-Layer surface 锁在 3 modalities (LongHold + Swing + Cash)。
<!-- /LES -->

<!-- LES | id: L014 | confidence: 0.92 | reinforced: 1 | date: 2026-05-23 | concepts: [naming-discipline, gate-collision, p-prefix, doctrine-drift] -->
[2026-05-23] [quant-arena/sprint-discipline] **P-prefix is reserved for binding exit gates; operational SLOs must use different labels**。Sprint-4 (#261) 给 slippage/fill-ratio/vol-tracking/halts 贴了 "P.2-P.5" 标签，但 G3-6 #257 §2 的 P.2-P.5 是另一组完全不同的 gate（reconciliation / kill-switch / KPI / risk-controller-test）。这是 doctrine drift 的典型样本——sprint 内 cargo-cult 复制前述 sprint 的 naming，没回去 cross-check binding doc。Sprint-5 (#262) 一次性修了 docstring 并 ship 了真正的 p_gates.py，但发现-修复 round-trip 是 1 个 PR 的浪费。
→ 关联规律：任何带 P/M/G 前缀的命名都需要 cross-check binding doc；review prompt 的 vote questions 也要 cite verbatim 而非 paraphrase。
→ 反向证据：Sprint-5 PR description 显式列出了 G3-6 verbatim definitions，避免了进一步 drift；mistake caught within 1 sprint window 而非埋到 G3-7 review。
<!-- /LES -->

<!-- LES | id: L015 | confidence: 0.95 | reinforced: 1 | date: 2026-05-23 | concepts: [stub-vs-vapor, ci-gating, production-readiness, vendor-integration] -->
[2026-05-23] [quant-arena/integration-design] **Vendor adapters that can't be exercised in CI must ship as loud stubs, not placeholder code**。Sprint-6 vnpy_xtquant.py 的 `__init__` 直接 raise NotImplementedError + 指向 plan doc，每个 BrokerProtocol method 也 raise。原因：vnpy + xtquant + QMT 需要 broker-side install + 真账户 credentials，CI 跑不了。Ship "placeholder that silently works" 的方案 = 让 typo-level mistake 把它从测试穿越到 live deploy；ship loud stub = compiler-style error at construction time，accidental production-path use 立即 crash。
→ 关联约定：任何 vendor-dependent adapter 缺少 CI 覆盖时，construction 必须 raise（不是 method-level lazy raise），且 error message 必须 cite 解锁该 stub 所需的 review / install 步骤。
→ 反向证据：Sprint-5 broker eval memo 排第二的 futu_openapi 也具有同样限制；如果 future PR 加 futu adapter，必须沿用同样的 loud-stub 模式。
<!-- /LES -->

<!-- LES | id: L016 | confidence: 0.88 | reinforced: 1 | date: 2026-05-23 | concepts: [risk-veto, partial-batch, expected-halt-doctrine, alert-vs-abort] -->
[2026-05-23] [quant-arena/risk-design] **Risk vetoes are append-only diagnostics, not silent drops**。PaperTradingOrchestrator (Sprint-4 #261) 收到 RiskViolation 时记 `risk_violations` tuple + emit alert + 跳过该 order，但 batch 中其它 order 继续 submit。这匹配 G3-6 P.5 doctrine "expected halt"——风控停单是预期的（已配置 cap 的自然 enforcement），不是 unexpected failure。如果 risk veto 让整个 batch 中止，会和 broker error 路径无法区分，违反 P.5 "zero unexpected halts" 的可测性。
→ 关联约定：任何 halt taxonomy 必须 pre-commit "expected prefixes"（默认: risk_violation, price_divergence_halt, manual_halt），caller 可以 override 但不能完全 disable。compute_halts() 据此分类。
→ 反向证据：DummyBroker 自己 reject 时 router 是 raise 的（Sprint-2）；orchestrator 在更上层把 broker reject 转成 alert 而非 raise。两层语义有意分离。
<!-- /LES -->

<!-- LES | id: L017 | confidence: 0.90 | reinforced: 1 | date: 2026-05-23 | concepts: [pr-cascade, auto-merge, github-update-branch, per-pr-auth] -->
[2026-05-23] [quant-arena/git-ops] **Per-PR explicit auth pattern + GitHub auto-merge + bulk update-branch = cascade velocity without L006 violation**。两个 session 内连续 merge 了 #258→#263 六个 Sprint PR，每个都走 "user say '自动合 #N' → agent run gh pr merge --auto --squash --delete-branch" 流程，单次 cascade 内允许 "授权你继续" 作为 bulk update-branch 的 standing auth。这保持了 L006 "继续 is ambiguous; merge to main needs explicit auth per PR" doctrine 同时不让 explicit prompt 成为 6-PR cascade 的 bottleneck。
→ 关联约定：merge to default branch 必须每 PR 显式 "自动合 #N"；同一 cascade 内的 bulk update-branch（非 destructive）可以单次 "授权你继续" 覆盖多轮 rebase。
→ 反向证据：Session 2026-05-19 早期一次 #228 governance fix 被 agent 提前 merge（user one-time accepted but did NOT relax rule）→ 直接催生 L006；Session 2026-05-23 整个 6-sprint cascade 都没再犯，pattern 工作良好。
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

<!-- LES | id: L018 | confidence: 0.92 | reinforced: 1 | date: 2026-05-25 | concepts: [validation-metric, sentiment, rank-ic, decile-spread, tail-alpha] -->
[2026-05-25] [quant-arena/validation] **Rank-IC ≠ decile-spread**：Spearman B.1 测的是 monotonic ordering across all deciles，会洗掉 tail-concentrated 信号。Sentiment-style 因子在极端 sentiment 上有方向性 alpha，但中段 80% 与 return 噪声主导 → rank-IC ≈ 0。诊断技巧：当 5 个相关因子 mean IC 都集中在 ±0.015 内（既不像有 alpha 也不像 random 的 ±0.05），先跑 decile-spread 看是否有 tail signal 被洗掉。修复模式：加 B.4 gate (top-bot decile mean spread t-stat ≥ 2)。
<!-- /LES -->

<!-- LES | id: L019 | confidence: 0.85 | reinforced: 1 | date: 2026-05-25 | concepts: [window-dependency, regime-shift, single-gate-pass, robustness-check] -->
[2026-05-25] [quant-arena/validation] **Single-window B.3 pass 可能 regime-specific**：sentiment_momentum 在 2024-2026 (350d) 过 B.3 p=0.009，但拆分到 2025-2026 sub-window (265d) 同因子 mean IC -0.0026 完全失败 (p=0.738)。Alpha 全在 2024 那 90 天。Before promoting：(1) 至少拆 2 个 sub-window 重跑 (2) 如果信号集中在一个 sub-period → 标 regime-specific risk + 收紧 risk band (max_position 减半)。Shadow trial 设计上吸收了这层不确定性，但应在 README 文档化。
<!-- /LES -->

<!-- LES | id: L020 | confidence: 0.95 | reinforced: 1 | date: 2026-05-25 | concepts: [ci-design, gate-semantics, shadow-trial, day-zero] -->
[2026-05-25] [quant-arena/ci] **Promotion gate ≠ admission gate**：promotion_gate_check 之前会在 ANY PR 引入新 candidate.yaml 时跑严格 gate，导致 day-0 状态（KPI 占位符 + shadow_days=0）必然 GATE VIOLATION → false-fail PR。修复模式：加 status=shadow + shadow_days<threshold 的 SHADOW PENDING 快通道 (exit 0 + 诊断信息)。语义正解：候选还在 shadow 期是"等待"不是"失败"；exit 2 只应 fire 在"试图 promote 但 KPI 不达标"。
<!-- /LES -->

<!-- LES | id: L021 | confidence: 0.90 | reinforced: 1 | date: 2026-05-25 | concepts: [background-process, kill, ps-grep, verification] -->
[2026-05-25] [quant-arena/ops] **Sub-shell kill 不一定杀掉长跑 Python**：`ps ... | xargs kill` 返回成功后，被 kill 的 Python 进程仍可能继续跑到自然结束 (~45 min later)，最终把已编辑的本地文件覆写回去（因为它们持有 file handle）。验证模式：`ps -ef | grep <pattern>` 等到真没结果再继续。修复反应：发现覆写后 `git checkout <file>` revert 单文件而非整个 working tree。
<!-- /LES -->

<!-- LES | id: L022 | confidence: 0.95 | reinforced: 1 | date: 2026-06-08 | concepts: [cognee, dashscope, litellm, embedding, openai-compatible, config] -->
[2026-06-08] [Claude_up/MCP配置] **cognee 接第三方 OpenAI 兼容端点（DashScope）三连坑**——每个都会让 add/cognify 静默挂：(1) **litellm 需 `provider/model` 前缀**：`LLM_MODEL=qwen-plus` 裸名触发 "LLM Provider NOT provided" → 连接测试 30s 超时 → add 直接挂；必须写 `openai/qwen-plus`。(2) **embedding 别用 `openai` provider**：会走 LiteLLMEmbeddingEngine → tiktoken 无法映射非 OpenAI 模型名（`text-embedding-v3`）报 KeyError；改 `EMBEDDING_PROVIDER=openai_compatible`（直接用 openai SDK + tokenizer 回退默认编码，且 model 名**不带**前缀）。(3) **维度/批量必须匹配后端**：`EMBEDDING_DIMENSIONS=1024`（cognee 默认 3072）+ `EMBEDDING_BATCH_SIZE=10`（DashScope v3 batch 上限 10，默认 36 → 400 InvalidParameter，一次灌库 840 次失败致图谱残缺）。补充：单用户库设 `ENABLE_BACKEND_ACCESS_CONTROL=false`；手动跑 CLI 要统一 export `DATA_ROOT_DIRECTORY`/`SYSTEM_ROOT_DIRECTORY`，否则数据落 venv 内部默认目录、add 与 search 各看各的。
<!-- /LES -->

<!-- LES | id: L023 | confidence: 0.9 | reinforced: 1 | date: 2026-06-08 | concepts: [debugging, cli-wrapper, python-api, traceback, error-hiding] -->
[2026-06-08] [Claude_up/排障] **CLI wrapper 吞异常时，降到底层库的 Python API 直接调用抓堆栈**：cognee-cli 把所有异常压成一句 "Please refer to our docs"，连官方 `--debug` flag 都不吐 traceback，排障卡死。绕过 CLI 写十来行 Python（`import cognee` + `asyncio.run(...)` + `traceback.print_exc()`）直接调 add/cognify，立刻拿到真实异常（`litellm.BadRequestError`）。通用模式：诊断 CLI 工具失败时若 CLI 隐藏错误，找它底层的库 API 在 Python 里直接调，错误无处可藏。
<!-- /LES -->

<!-- LES | id: L024 | confidence: 0.95 | reinforced: 1 | date: 2026-06-08 | concepts: [mcp, claude-code, codex, registration, claude.json, settings.json, wrapper, cross-tool] -->
[2026-06-08] [Claude_up/MCP机制] **MCP server 注册在 `~/.claude.json`（用 `claude mcp add`），不是 `~/.claude/settings.json` 的 mcpServers**——Claude Code v2.1.x 根本不读 settings.json 的 mcpServers 块。之前 filesystem/playwright/context7/github/cognee 全配在 settings.json，结果一个都没加载（`claude mcp list` 只有 feishu），这才是"cognee 从没出现"的真根因（比 L022 配置内容更底层），**推翻旧 L003**（"settings.json mcpServers 只对 CLI 生效"——错的）。正确做法：`claude mcp add <name> -s user -- <cmd> <args...>`。带密钥的 server 用 wrapper 脚本从环境/.zshrc 读 key（`-- /path/wrapper.sh`），~/.claude.json 里 env `{}` 零硬编码。**跨工具**：Codex CLI 用 `~/.codex/config.toml` 的 `[mcp_servers.<name>]`（command/args/startup_timeout_sec）指向同一 wrapper → Claude 与 Codex 共享同一 cognee 知识图谱。经典 Desktop 纯聊天走 `claude_desktop_config.json` 的 mcpServers（与 code session 的 ~/.claude.json 分离）。
<!-- /LES -->

<!-- LES | id: L025 | confidence: 0.85 | reinforced: 1 | date: 2026-06-08 | concepts: [cognee, mcp, lock, ladybug, process-leak, concurrency] -->
[2026-06-08] [Claude_up/运维] **cognee-mcp 进程退出不清理 + graph DB 单写锁**：每次 `claude mcp list` 健康检查 / MCP 测试都 spawn 一个 cognee-mcp，客户端断开后进程常**残留**（本会话累积 6 个孤儿）。ladybug/kuzu graph DB 是**单写锁**，残留进程占着锁 → 其它 cognee 访问（Python API / CLI / 另一 host）报 `Could not set lock on file cognee_graph_ladybug`。影响：Claude + Codex + Desktop 都注册了 cognee 共享同一图谱，**并发使用会撞锁**。排查 `ps -eo pid,command | grep 09-cognee/.venv`；清理 `pkill -f "09-cognee/.venv/bin/cognee-mcp"`。规避：同一时刻只让一个 host 用 cognee；批量 re-sync 先清残留进程，或走当前会话已连的 MCP 工具（经持锁进程操作，避开冲突）。
<!-- /LES -->
