# 周报：2026-W21 — 2026-05-18 → 2026-05-21（截至发稿）

> 项目：quant-arena SAMA framework  
> 节奏：高强度三天（周一启动 / 周二+周三主体落地 / 周四收尾），周四下午起准备休整

## 本周完成

### 主要交付（quant-arena · SAMA framework）

**5/19 周一（Tier 2 收官 + Tier 3 启动）**
- Tier 2 闭包：14 PR 单日推动 → no-go-gate doctrine 锁定（5/5 hyperopt rejected → forbidden knob spaces 入档）
- Tier 3 Phase A 启动：Q6 多轮调研，确认 R-Layer Brier 在 0.20 不可达

**5/19 晚 + 5/20（Tier 3 主体）**
- 18 PR（#210–#227）：Phase A 14 PR + Phase B scoping 4 PR
- **Phase A CLOSED**（事实层）：A.2 calibration 0.20→0.25 gate revision；A.4 30d shadow 在跑
- Phase B scoping（#225）+ G3-2 multi-model review（14/14 APPROVE w/ M6–M10 binding mods）
- Phase E G3-3 review（8/8 APPROVE w/ M11–M20 binding mods）+ M15 architecture memo

**5/20 → 5/21（Sprint-3 落地 + 收尾）**
- **13 PR cascade（#229–#241）** + #228 + #242：Phase B/E 全主体落地
- RegimeConditionalRouter 完整实现（46 tests）+ M-Layer engines scaffold + B.1/B.2/B.3 validation suite
- FactorSource Protocol + Phase5FactorSource + Pipeline Smoke 端到端
- 8 个 surgical CI fix（mypy 3.10 SequenceNotStr / Series narrow / np.ndarray 泛型 / ruff format / core↛markets 隔离重构）
- 今日（5/21）收尾：M1/M2 methodology PR #243 开 + 5 个 stale R-Layer PR #220–#224 close + 本地仓刷新 + 双 clone 状态梳理

### 进行中
- **PR #243** M1/M2 4+4 factor pre-commitment：等 CI + user merge
- **cifix clone**（1.3 GB）等用户手动 rm（classifier 拦不让 agent rm）
- **stash@{0}**（SAMA proposal 归档未完成，价值低）保留作未来 small task

## 阻塞与风险

| 问题 | 影响 | 解决方向 |
|------|------|---------|
| Phase B 真数据 invocation 未做 | M-Layer validation 还在 mock 数据层，没拿到真 Sharpe | #243 merge 后装 hmmlearn+alpha191，跑 B.1/B.2/B.3 |
| Phase E Sprint-0 M11 audit 未启 | Phase E 实施阻塞在 M11 第一条 binding mod | 与 Phase B validation 可并行 |
| Mac mini A3 unload 1/12 成功率 | 跨机器 cron 任务可靠性差 | 长期看需要排查；本周不阻塞 SAMA |
| GitHub Actions billing 撞过限额 | 一度让 CI 全 3-4s fail | 用户已加额，但要意识到限额会反噬开发节奏 |

## 下周计划（2026-W22, 5/25 → 5/31）

**优先级最高（必须完成）：**
1. #243 merge → M1/M2 8-factor 锁定 → 装依赖 → **Phase B 真数据 B.1/B.2/B.3 invocation**（confirmatory backtest，no-go-gate 走法）
2. 根据 B.1/B.2/B.3 结果决定 Phase B 是 validation-pass 还是触发 no-go-gate

**计划完成（如有时间）：**
3. Phase E Sprint-0 M11 audit 启动（与 Phase B 并行）
4. cifix 手动清理 + stash@{1} SAMA proposal 归档补完
5. Mac mini A3 unload 失败率问题排查（长期挂账）

## 认知沉淀（本周新增 3 条 lessons）

> **L007（mypy 3.10 严于 3.11+）**：本地 venv 过 ≠ CI 矩阵过。`pd.Series.reindex(Sequence[str])` 需 `list(universe)`；`panel.loc[ts]` / `series.xs()` 返回 union 需 isinstance 收窄；`np.ndarray` 泛型用 `npt.NDArray[np.float64]`。CI 矩阵必须本地多版本验证。

> **L008（squash-merge cascade 冲突分类）**：每个 PR 在 cascade 中 rebase 时，冲突文件分两类：本 PR OWN 的 `--ours`，upstream squash 进 main 的 `--theirs`。判定靠 `git log origin/main..origin/<pr-branch> --name-only`。错用方向会把已 land 的 CI fix 覆盖回旧版本。

> **L009（core/↛markets/ 隔离的破口）**：governance 用 AST-grep，lazy import 也算违规。Phase5FactorSource 这种 production wrapping 必须把 wiring 层抽到 `markets/cn_a_share/factors/_phase5_wiring.py`，core/ 只承诺 Callable 接口。

**额外洞察**：
- **Cherry-pick 是验证 PR 内容是否冗余的最快工具**：今天的 #223/#224 都靠 `git cherry-pick X` → "empty cherry-pick" 一秒确认内容已 squash 进 main，避免了无谓的 rebase 工作。
- **L006 在本周复盘**：3 天 32 PR 推动中没再触发 "继续" 模糊授权 incident → AskUserQuestion + 用户手动 merge 的 pattern 跑通了；agent 自觉性建立。
- **双 clone（dirty WT + clean clone）模式有效**：13 PR cascade 期间，cifix clean clone 是 CI fix 的隔离 workspace，避免污染主 WT；但 1.3 GB 占用 + 21 个本地 branch 是收尾负担。下次应直接在 worktree（git worktree add）替代 clone。

## 个人状态

- **精力**：充沛
- **节奏感**：高效（Phase A CLOSED + Phase B 主体落地进度超预期）
- **备注**：连续高强度三天可承受；下周走完 B.1/B.2/B.3 真数据 invocation 是收官关键。
