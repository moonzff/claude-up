# Claude_up Roadmap

## Phase 0 — Survey ✅ Complete (2026-05-07)
Environment survey, Codex_up analysis, platform capability mapping, dual-scenario cognitive framework.
Artifacts: `00-overview/20260507_research_v0.1_*.md`, `00-overview/20260507_research_v0.2_*.md`

## Phase 1 — Safety Baseline ✅ Complete (2026-05-07)
- [x] Claude_up directory skeleton
- [x] `settings.json` template + deployment to `~/.claude/`
- [x] `CLAUDE.md` template + deployment to `~/.claude/`
- [x] filesystem MCP configured
- [x] Deployment script with dry-run default (`install_claude_app.ps1`)

## Phase 2 — Core Skills ✅ Complete (2026-05-07)
6 skills covering both scenarios:
- Dev: `dual-environment-workflow` · `diagnose` · `grill-plan`
- Assistant: `research-object-archive` · `summarize-meeting` · `weekly-review`

## Phase 3 — Hooks Core Set ✅ Complete (2026-05-07)
4 deterministic hooks: `pre-bash-audit` · `post-write-format` · `stop-session-summary` · `post-write-research`

## Phase 4 — MCP Expansion ✅ Complete (2026-05-07)
playwright + context7 MCPs added. Deployment script updated.

## Phase 5 — Diagnostic CLI ✅ Complete (2026-05-07)
`cli/claude_app.ps1` — 6 commands: doctor / mcp-check / skill-list / config-validate / memory-audit / deploy-dry-run

## Phase 6 — Packaging ✅ Complete (2026-05-07)
Profile-aware installer (`-Profile dev|assistant|full`), BOOTSTRAP.md, VERSION file.

## Phase 7 — External Intelligence Layer ✅ Complete (2026-05-09)
- GitHub MCP configured (requires `GITHUB_TOKEN` env var to activate)
- Letta MCP configured (requires local Letta server to activate)
- `08-memory/` file-based memory layer — functional today, zero dependencies

## Phase 8 — Dev Skills Expansion ✅ Complete (2026-05-09)
- `grill-plan` upgraded to v2 (Ouroboros evolution loop)
- `memory-update` skill added (session protocols)
- `10-skill-library/` established with 9 on-demand skills
- superpowers pipeline: sp-brainstorming · sp-writing-plans · sp-executing-plans
- Dev skills: code-review · security-audit · api-design · sp-tdd
- Sourced from: obra/superpowers · wshobson/agents

## Phase 9 — Memory System Upgrade ✅ Complete (2026-05-10)
- `08-memory/` upgraded from 3-tier (Letta) to 4-tier (+ semantic/)
- `memory-update` SKILL v2.0: confidence scoring, memory evolution, contradiction check, semantic distillation
- `semantic/patterns.md` — 4 recurring patterns with evidence chains
- `semantic/conventions.md` — 5 established conventions
- 2 new skills from superpowers-zh: `systematic-debugging` · `verification-before-completion`
- `task-master` skill guide added to library
- Absorbed design principles from: agentmemory · superpowers-zh · claude-task-master

## Phase 10 — Tooling & Deep Research ✅ Complete (2026-05-10)
- `tooling/ccusage.md` — Token usage tracking guide
- `tooling/README.md` — Companion tools index
- `08-memory/templates/` — Anonymized starter templates for personal memory files
- README rewritten (bilingual EN + ZH), README_ZH.md created
- LICENSE (MIT) added
- `.gitignore` updated to protect personal memory data
- Public GitHub release: v0.9.0

## Phase 11 — Planned: Task Master Pilot
- [ ] Pilot `claude-task-master` on 杆杆响会员服务 project via Claude Code CLI
- [ ] Document learnings in `tooling/task-master-pilot.md`
- [ ] Evaluate integration with sp-executing-plans workflow

## Phase 12 — Planned: System Prompt Study
- [ ] Read [claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts)
- [ ] Extract insights for CLAUDE.md optimization
- [ ] Identify any conflicts/redundancies between Claude_up and built-in prompts
- [ ] Optimize token budget in global CLAUDE.md

## Phase 13 — Planned: MCP Expansion
- [ ] Evaluate database MCP for 杆杆响 project
- [ ] Evaluate financial data MCP for quant-trading project
- [ ] Reference: [awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers)

---

## Version History

| Version | Date | Milestone |
|---------|------|-----------|
| v0.6.0 | 2026-05-07 | Initial release: Phases 0–6 complete |
| v0.6.1 | 2026-05-08 | grill-plan v2 (Ouroboros loop) |
| v0.7.0 | 2026-05-09 | GitHub MCP + Letta MCP + 08-memory/ 3-tier |
| v0.7.1 | 2026-05-09 | 08-memory/ refactored to Letta 3-tier architecture |
| v0.8.0 | 2026-05-09 | 10-skill-library/ + superpowers + Dev Skills |
| v0.8.1 | 2026-05-09 | systematic-debugging + verification-before-completion |
| v0.9.0 | 2026-05-10 | Memory system 4-tier + confidence scoring + tooling + public release |
